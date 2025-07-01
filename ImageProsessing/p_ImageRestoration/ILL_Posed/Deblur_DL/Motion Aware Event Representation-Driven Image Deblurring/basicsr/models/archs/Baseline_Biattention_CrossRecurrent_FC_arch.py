import sys
from basicsr.utils.registry import ARCH_REGISTRY
import torch
import torch.nn as nn
import math
from basicsr.models.archs.arch_util import EventImage_BiAttentionTransformerBlockwithFC, LayerNorm2d, Sparsemask
from torch.nn import functional as F
from thop import profile

class BaselineBlock(nn.Module):
    def __init__(self, c, DW_Expand=1, FFN_Expand=2, drop_out_rate=0., num_heads=None):
        super().__init__()
        dw_channel = c * DW_Expand
        self.num_heads = num_heads
        
        self.conv1 = nn.Conv2d(in_channels=c, out_channels=dw_channel, kernel_size=1, padding=0, stride=1, groups=1, bias=True)
        self.conv2 = nn.Conv2d(in_channels=dw_channel, out_channels=dw_channel, kernel_size=3, padding=1, stride=1, groups=dw_channel,
                               bias=True)
        self.conv3 = nn.Conv2d(in_channels=dw_channel, out_channels=c, kernel_size=1, padding=0, stride=1, groups=1, bias=True)
        
        # Channel Attention
        self.se = nn.Sequential(
            nn.AdaptiveAvgPool2d(1),
            nn.Conv2d(in_channels=dw_channel, out_channels=dw_channel // 2, kernel_size=1, padding=0, stride=1,
                      groups=1, bias=True),
            nn.ReLU(inplace=True),
            nn.Conv2d(in_channels=dw_channel // 2, out_channels=dw_channel, kernel_size=1, padding=0, stride=1,
                      groups=1, bias=True),
            nn.Sigmoid()
        )

        # GELU
        self.gelu = nn.GELU()

        ffn_channel = FFN_Expand * c
        self.conv4 = nn.Conv2d(in_channels=c, out_channels=ffn_channel, kernel_size=1, padding=0, stride=1, groups=1, bias=True)
        self.conv5 = nn.Conv2d(in_channels=ffn_channel, out_channels=c, kernel_size=1, padding=0, stride=1, groups=1, bias=True)

        self.norm1 = LayerNorm2d(c)
        self.norm2 = LayerNorm2d(c)

        self.dropout1 = nn.Dropout(drop_out_rate) if drop_out_rate > 0. else nn.Identity()
        self.dropout2 = nn.Dropout(drop_out_rate) if drop_out_rate > 0. else nn.Identity()

        self.beta = nn.Parameter(torch.zeros((1, c, 1, 1)), requires_grad=True)
        self.gamma = nn.Parameter(torch.zeros((1, c, 1, 1)), requires_grad=True)
        
        if self.num_heads is not None:
            self.image_event_transformer = EventImage_BiAttentionTransformerBlockwithFC(c, num_heads=self.num_heads,
                                                                                       ffn_expansion_factor=4, bias=False,
                                                                                       LayerNorm_type='WithBias')

    def forward(self, inp, event_filter=None):
        x = inp

        x = self.norm1(x)

        x = self.conv1(x)
        x = self.conv2(x)
        x = self.gelu(x)
        x = x * self.se(x)
        x = self.conv3(x)
        if self.num_heads:
            assert event_filter != None
            x = self.image_event_transformer(x, event_filter) # x=b,c,h,w

        x = self.dropout1(x)

        y = inp + x * self.beta

        x = self.conv4(self.norm2(y))
        x = self.gelu(x)
        x = self.conv5(x)

        x = self.dropout2(x)

        return y + x * self.gamma
    
class BaselineBlock_seq(nn.Module):
    def __init__(self, c, DW_Expand=1, FFN_Expand=2, drop_out_rate=0., num_heads=None,n_block=2):
        super().__init__()
        self.fusion = BaselineBlock(c, DW_Expand=DW_Expand, FFN_Expand=2, drop_out_rate=drop_out_rate, num_heads=num_heads)
        self.seq_block = nn.Sequential(
            *[BaselineBlock(c, DW_Expand=DW_Expand, FFN_Expand=2, drop_out_rate=drop_out_rate, num_heads=None) for _ in range(n_block-1)]
        )
    
    def forward(self, inp, event_filter=None):
        x = inp
        
        x = self.fusion(x, event_filter)
        x = self.seq_block(x)
        
        return x

class RecurrentBaseBlock(nn.Module):
    def __init__(self,chan,num,dw_expand,ffn_expand):
        super(RecurrentBaseBlock,self).__init__()
        self.nowencoder = nn.Sequential(
                    *[BaselineBlock(chan,dw_expand,ffn_expand) for _ in range(num)]
        )
        self.lastencoder = BaselineBlock(chan,dw_expand,ffn_expand)
        self.alpha = nn.Parameter(torch.zeros((1, chan, 1, 1)), requires_grad=True)
    def forward(self,eventlist):
        statels = []
        for i in range(len(eventlist)):
            now = self.nowencoder(eventlist[i])
            if i == 0:
                # temp = torch.zeros_like(now)
                # last = self.lastencoder(temp)
                new = now 
                statels.append(new)
                continue
            last = self.lastencoder(statels[i-1])
            new = now * (1-self.alpha)  + last * self.alpha
            statels.append(new)
        return statels

class MakeRecurrentList(nn.Module):
    def __init__(self):
        super(MakeRecurrentList,self).__init__()
    def forward(self,event):
        B ,C ,H, W = event.shape
        chunks = event.chunk(C,dim=1)
        listlen = int(C/2)
        eventlist = []
        for i in range(listlen):
            temp_y = torch.cat([chunks[i],chunks[-1-i]],dim=1)
            eventlist.append(temp_y)
        return eventlist

# @ARCH_REGISTRY.register()
class Baseline_Biattention_CrossRecurrent_FC(nn.Module):
    def __init__(self, in_chn=3, ev_chn=7, width=16,
                middle_blk_num=1, enc_blk_nums=[], dec_blk_nums=[],
                dw_expand=1, ffn_expand=2,
                num_heads=[1,2,4]):
        super().__init__()
        
        self.num_heads = num_heads
        
        self.intro = nn.Conv2d(in_channels=in_chn, out_channels=width, kernel_size=3, padding=1, stride=1, groups=1,
                              bias=True)
        self.makelist = MakeRecurrentList()
        self.ev_intro = nn.Conv2d(in_channels=2, out_channels=width, kernel_size=3, padding=1, stride=1, groups=1,
                              bias=True)
        self.ending = nn.Conv2d(in_channels=width, out_channels=in_chn, kernel_size=3, padding=1, stride=1, groups=1,
                              bias=True)
        self.cross = nn.Conv2d(in_channels=in_chn+2,out_channels=in_chn,kernel_size=3, padding=1, stride=1, groups=1,bias=True)
        
        self.encoders = nn.ModuleList()
        self.decoders = nn.ModuleList()
        self.middle_blks = nn.ModuleList()
        self.ups = nn.ModuleList()
        self.downs = nn.ModuleList()
        
        self.ev_encoders = nn.ModuleList()
        self.ev_downs = nn.ModuleList()
        
        
        chan = width
        for i, num in enumerate(enc_blk_nums):
            self.encoders.append(
                BaselineBlock_seq(chan, dw_expand, ffn_expand,num_heads=self.num_heads[i],n_block=num)
            )
            self.ev_encoders.append(
                RecurrentBaseBlock(chan,num,dw_expand,ffn_expand)
            )
            self.downs.append(
                nn.Conv2d(chan, 2*chan, 2, 2)
            )
            self.ev_downs.append(
                nn.Conv2d(chan, 2*chan, 2, 2)
            )
            chan = chan * 2

        self.middle_blks = \
            nn.Sequential(
                *[BaselineBlock(chan, dw_expand, ffn_expand) for _ in range(middle_blk_num)]
            )
            
        for num in dec_blk_nums:
            self.ups.append(
                nn.Sequential(
                    nn.Conv2d(chan, chan * 2, 1, bias=False),
                    nn.PixelShuffle(2)
                )
            )
            chan = chan // 2
            self.decoders.append(
                nn.Sequential(
                    *[BaselineBlock(chan, dw_expand, ffn_expand) for _ in range(num)]
                )
            )
    
    def forward(self, x, event=None, mask=None, gt=None):
        x_ = self.intro(x)
        eventlist = self.makelist(event)
        e1 = []

        for i in range(len(eventlist)):
            ev_x = self.ev_intro(eventlist[i])
            e1.append(ev_x)
        
        
        ev = []
        #event encoder
        for encoder, down in zip(self.ev_encoders, self.ev_downs):
            e1 = encoder(e1)
            ev.append(e1[-1])
            for i in range(len(e1)):
                e1[i] = down(e1[i])
        
        encs = []
        #image encoder
        for encoder, down, ev_feature in zip(self.encoders, self.downs, ev):
            x_ = encoder(x_, ev_feature)
            encs.append(x_)
            x_ = down(x_)
        
        x_ = self.middle_blks(x_)
        
        for decoder, up, enc_skip in zip(self.decoders, self.ups, encs[::-1]):
            x_ = up(x_)
            x_ = x_ + enc_skip
            x_ = decoder(x_)
        
        x_ = self.ending(x_)
        x_ = torch.cat([x_,eventlist[-1]],dim=1)
        x_ = self.cross(x_)

        x_ = x_ + x
        
        return x_
