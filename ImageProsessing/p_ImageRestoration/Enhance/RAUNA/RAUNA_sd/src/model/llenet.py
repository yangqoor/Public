import torch
torch.cuda.current_device()
import torch.nn as nn
import torch.nn.functional as F
import cv2
import numpy as np
import torchvision
from torchvision import transforms
import matplotlib.pyplot as plt
import matplotlib
#matplotlib.use('agg')
#修改了padding方式 reflect

from .utils import Diffusion, parse_args_and_config


# 梯度核定义（对应 d_x 和 d_y）
kernel_y = torch.FloatTensor([[[[-1.0, 0, 1.0]]]]).expand(3, 1, -1, -1)
kernel_x = torch.transpose(kernel_y, dim0=2, dim1=3)
#gradient kernel
# kernel_y_g = torch.FloatTensor([[[[-1.0, 0, 1.0]]]]).expand(3, 1, -1, -1)
# kernel_x_g = torch.transpose(kernel_y_g, dim0=2, dim1=3)

kernel_r = 1/25 * torch.ones(size=(5,5)).unsqueeze(dim=0).unsqueeze(dim=0).expand(3,1,-1,-1)
# kernel_z = 1/9*torch.ones(size=(3,3)).unsqueeze(dim=0).unsqueeze(dim=0)


def make_model(args, parent=False):
    return Mainnet(args)

class Mainnet(nn.Module):
    def __init__(self, args):
        super(Mainnet, self).__init__()
        import pdb
        # pdb.set_trace()
        self.args = args
        self.S = args.stage# 迭代阶段数（对应公式中的优化步数
        self.iter = self.S-1
        self.conv_channels = args.conv_channels
        self.device = torch.device('cpu' if args.cpu else 'cuda')


        #parameters
        self.lam = nn.Parameter(torch.FloatTensor([11]), requires_grad=True)
        self.sigma = nn.Parameter(torch.FloatTensor([.1]), requires_grad=True)
        self.gamma = nn.Parameter(torch.FloatTensor([args.gam]), requires_grad=True)
        self.eps = nn.Parameter(torch.FloatTensor([0.02]), requires_grad=True)
        self.gam1 = self.make_eta(self.iter, self.gamma)  #gamma在每个阶段更新
        # self.weight = nn.Parameter(torch.FloatTensor([1.3]), requires_grad=False)

        # # para of R0
        # # TODO: Update
        # self.lam0 = nn.Parameter(torch.FloatTensor([9]), requires_grad=False)
        # self.sigma0 = nn.Parameter(torch.FloatTensor([0.1]), requires_grad=False)

        # Stepsize
        #TODO: etaL
        self.etaL = torch.Tensor([1.])  # initialization
        self.etaR = torch.Tensor([1.])  # initialization
        self.eta1 = nn.Parameter(self.etaL, requires_grad=True)  # usd in initialization process
        self.eta2 = nn.Parameter(self.etaR, requires_grad=True)  # usd in initialization process
        self.eta11 = self.make_eta(self.iter, self.etaL)  # usd in iterative process
        self.eta12 = self.make_eta(self.iter, self.etaR)
        # self.meanr = nn.Parameter(torch.FloatTensor([0.44]), requires_grad=True)
        # self.stdr = nn.Parameter(torch.FloatTensor([0.18]), requires_grad=True)
        # self.meang= nn.Parameter(torch.FloatTensor([0.42]), requires_grad=True)
        # self.stdg = nn.Parameter(torch.FloatTensor([0.20]), requires_grad=True)
        # self.meanb= nn.Parameter(torch.FloatTensor([0.44]), requires_grad=True)
        # self.stdb = nn.Parameter(torch.FloatTensor([0.21]), requires_grad=True)

        #  kernel
        #TODO: May update
        self.weight0_x = nn.Parameter(data=kernel_x, requires_grad=False)  # used in initialization process
        # self.conv_x = self.make_weight(self.iter, kernel_x)
        self.weight0_y = nn.Parameter(data=kernel_y, requires_grad=False)  # used in initialization process
        # self.conv_y = self.make_weight(self.iter, kernel_y)
        #TODO：update
        self.fuz = nn.Parameter(data=kernel_r, requires_grad=False)  # used in L0 cannot update

        # gradient kernel
        # self.weight0_x_g = nn.Parameter(data=kernel_x_g, requires_grad=False)
        # self.weight0_y_g = nn.Parameter(data=kernel_y_g, requires_grad=False)

        #proxnet in initialization
        self.num_L = args.num_L
        self.num_R = args.num_R
        self.lnet = Lnet(self.num_L+5)
        self.rnet = Rnet(self.num_R+3)
        self.l_stage = self.make_lnet(self.S, self.num_L+5) # L的更新模块
        self.r_stage = self.make_rnet(self.S, self.num_R+3)  # R的更新模块
        # self.lnet = Lnet(self.num_L)
        # self.l_stage = self.make_lnet(self.S, self.num_L)

# TODO:finetune
#         self.frnet = Rnet(self.num_R+3) #finetune
        # self.r0net = R0net(3)

        # # self.kernel_z_l = kernel_z.expand(self.num_L,3,-1,-1)
        # self.w_l_f = nn.Parameter(self.kernel_z_l, requires_grad=True)
        # self.kernel_z_r = kernel_z.expand(self.num_R,3,-1,-1)
        # self.w_r_f = nn.Parameter(self.kernel_z_r, requires_grad=True)
        self.cnt = 0
        self.conv_l = nn.Conv2d(in_channels=1,out_channels=self.num_L, kernel_size=3, stride=1, padding=1,
                                padding_mode='reflect')
        self.conv_r = nn.Conv2d(in_channels=3, out_channels=self.num_R, kernel_size=3, stride=1, padding=1,
                                padding_mode='reflect')
        # self.kernel_z = kernel_z.expand(self.num_R, 3, -1, -1)
        # self.w_f = nn.Parameter(self.kernel_z, requires_grad=True)

    def make_lnet(self, iters, channel):
        layers = []
        for i in range(iters):
            layers.append(Lnet(channel))
        return nn.Sequential(*layers)

    def make_rnet(self, iters, channel):
        layers = []
        for i in range(iters):
            layers.append(Rnet(channel))
        return nn.Sequential(*layers)

    def make_eta(self, iters,const):
        const_dimadd = const.unsqueeze(dim=0)
        const_f = const_dimadd.expand(iters, -1)
        eta = nn.Parameter(data=const_f, requires_grad=True)
        return eta

    def make_weight(self, iters, const):
        const_dimadd = const.unsqueeze(dim=0)
        const_f = const_dimadd.expand(iters, -1, -1, -1, -1)
        weight = nn.Parameter(data=const_f, requires_grad=True)
        return weight


    def forward(self, input, df_model, betas, config):
        # x0_hat, x1_hat = None, None
        # save mid-updating results
        ListR = []
        ListL = []
        padding_x = (0, 0,
                     1, 1)
        padding_y = (1, 1,
                     0, 0)


        #initialization
        # #TODO: Para of R
        R0 = torch.zeros(input.shape).to(self.device)
        R0[:, 0, :, :] = (input[:, 0, :, :] - torch.mean(input[:, 0, :, :]) + 0.0001) / (
                torch.std(input[:, 0, :, :]) + 0.0001) * 0.2349 + 0.4327
        R0[:, 1, :, :] = (input[:, 1, :, :] - torch.mean(input[:, 1, :, :]) + 0.0001) / (
                torch.std(input[:, 1, :, :]) + 0.0001) * 0.2062 + 0.4136
        R0[:, 2, :, :] = (input[:, 2, :, :] - torch.mean(input[:, 2, :, :]) + 0.0001) / (
                torch.std(input[:, 2, :, :]) + 0.0001) * 0.2344 + 0.4869
        # grey = torch.FloatTensor([0.299,0.587,0.144]).unsqueeze(dim=0).unsqueeze(dim=2).unsqueeze(dim=3).to(self.device)
        # L0 = torch.sum(input*grey,dim=1).unsqueeze(dim=1)
        L0,_ = torch.max(input, dim=1)
        L0 = L0.unsqueeze(dim=1)
        # R0 = input * (2 - input)
        # L0 = ((input+0.0001)/(R0 + 0.0001)).mean(dim=1).unsqueeze(dim=1)

###########################################

        # 1st iteration: updating: R0 > L1
        #############################################################
        U0 = torch.sum(R0*(R0*L0-input), dim=1)
        H0 = torch.sum(R0 * R0, dim=1)
        dL0 = torch.div(U0+0.0001, H0+0.0001).unsqueeze(dim=1) #avoid div 0
        Z0_L = self.conv_l(L0) #dim=29
        # L = L0 - self.eta1 * dL0
        # M0 = torch.div(input+0.0001, R0+0.0001).unsqueeze(dim=1)
        Z0_L_R = torch.cat((R0,Z0_L),dim=1) #dim=3+29
        L_d = torch.cat((L0,dL0,Z0_L_R),dim=1) #dimension=1+1+3+29
        # L_cat = torch.cat((L, Z0_L), dim=1)
        L_cat_new = self.l_stage[0](L_d)
        L = L_cat_new[:, :1, :, :]
        Z_L = L_cat_new[:, 5:, :, :]

        ListL.append(L)


        # R = R_cat_new[:, :3, :, :]  # 输出更新后的反射层
        from model.utils import diffusion_prior
        L_ = F.interpolate(L.repeat(1, 3, 1, 1), 
                                size=(256, 256), 
                                mode='bilinear', 
                                align_corners=False
                                )
        x0, x1 = diffusion_prior(L_, df_model, betas, config)
        x0_hat = F.interpolate(x0, 
                                size=L.shape[2:], 
                                mode='bilinear', 
                                align_corners=False
                                )
        x1_hat = F.interpolate(x1,
                                size=L.shape[2:],
                            mode='bilinear',
                            align_corners=False
                            )
        R =(x1_hat * L -input) * L + x0_hat

        # Z_R = R[:, 3:, :, :]  # 保留隐式特征供后续迭代使用

        ListR.append(R)



        config =parse_args_and_config(self.args)
        runner = Diffusion(self.args,config)
        A_hat = runner.sample()
        A_hat_upsampled = F.interpolate(A_hat,
                                        size=A.shape[2:],
                                        mode='bilinear',
                                        align_corners=False)
        # 综合数据保真项和先验项计算梯度更新量(公式6整体寻数)
        dR0 =(A + self.gamma*(R0-A_hat_upsampled))/(L*L+self.gamma) # 分母包含Hessian矩阵近似项

        R0_update= R0 - self.eta2* dR0 # eta2为反射层的学习率参数
        # 通过残差网络模块融合显式先验和险式先验(对应论文图2(b)的r-stage模块)
        Z0_R= self.conv_r(R0) # 隐式特征提取
        R_cat = torch.cat((R0_update,Z0_R),dim=1) # 连接显式更新和隐式特征
        R_cat_new = self.r_stage[0](R_cat) 
        # 通过可学习的网络模块优化
        R=R_cat_new[:,:3,:,:] # 出更新后的反射层
        ZR=R_cat_new[:,3:,:,:] # 保留隐式特征供后续送代使用
        ListR.append(R)

        # 根据论文第III-B节Retinex分解网络设计(对应公式6)
        # 本部分对应算法展开中的多阶段迭代优化过程，交替更新光照层(L)和反射层(R)
        for i in range(self.iter):  # self.iter = args.stage-1 表示总迭代次数
            # ============== 光照层(L)更新步骤 ==============
            # 计算光照层优化目标函数的数据保真项导数(对应公式6第一项导数)
            U = torch.sum(R * (R * L - input), dim=1)          # 分子项：梯度计算
            H = torch.sum(R * R, dim=1)                         # 分母项：Hessian矩阵近似
            dL = torch.div(U+0.0001, H+0.0001).unsqueeze(dim=1) # 光照层梯度更新量
            
            # 构建隐式特征融合输入：连接当前反射层(R)、隐式特征(Z_L)和梯度信息(dL)
            Z_L_R = torch.cat((R,Z_L),dim=1)                    # 反射层与隐式特征拼接
            L_d = torch.cat((L,dL,Z_L_R),dim=1)                 # 当前光照层、梯度与特征拼接
            
            # 通过可学习的l_stage模块优化光照层(对应图2(b)的l_stage结构)
            L_cat_new = self.l_stage[i + 1](L_d)                # 网络模块处理融合特征
            # L_1 = L                                             # L_1为上一个阶段的光照层
            L = L_cat_new[:, :1, :, :]                          # 提取更新后的光照层
            Z_L = L_cat_new[:, 5:, :, :]                        # 保留隐式特征供后续迭代
            
            ListL.append(L)  # 保存当前阶段的光照层结果

            # ============== 反射层(R)更新步骤 ==============
            # 计算反射层优化目标函数的数据保真项(对应公式6第一项导数)
            # A = R * L * L - input * L                           # 数据保真项导数
            
            # 计算结构揭示先验项(对应公式6第四项的梯度匹配项)
            # 计算输入图像的水平/垂直梯度并进行阈值处理和归一化
            # input_x = F.pad(input, padding_x, mode='reflect')   # 水平方向反射填充
            # DIx = F.conv2d(input_x, weight=self.weight0_x, stride=1, padding=0,groups=3)
            # DIx = DIx * (torch.abs(DIx) >= self.eps)            # 梯度阈值处理
            # DIx = DIx / (input_std * 2)                         # 标准差归一化
            # # 计算结构增强项Gx(对应论文中的指数加权梯度增强)
            # Gx = (1 + self.lam * torch.exp(-torch.abs(DIx)/self.sigma)) * DIx
            
            # # 同理计算垂直方向梯度Gy
            # input_y = F.pad(input, padding_y, mode='reflect')
            # DIy = F.conv2d(input_y, weight=self.weight0_y, stride=1, padding=0, groups=3)
            # DIy = DIy * (torch.abs(DIy) >= self.eps)
            # DIy = DIy / (input_std * 2)
            # Gy = (1 + self.lam * torch.exp(-torch.abs(DIy)/self.sigma)) * DIy

            # # 计算反射层梯度与结构增强项的差异(对应先验项的梯度匹配)
            # R_x = F.pad(R, padding_x, mode='reflect')
            # A_tilda_x = F.conv2d(R_x, weight=self.weight0_x, stride=1, padding=0,groups=3) - Gx
            # R_y = F.pad(R, padding_y, mode='reflect')
            # A_tilda_y = F.conv2d(R_y, weight=self.weight0_y, stride=1, padding=0,groups=3) - Gy
            
            # # 通过转置卷积计算先验项的梯度方向(反向传播结构先验损失)
            # A_hat_x = F.conv_transpose2d(A_tilda_x, self.weight0_x, stride=1, padding=(1,0), groups=3)
            # A_hat_y = F.conv_transpose2d(A_tilda_y, self.weight0_y, stride=1, padding=(0,1), groups=3)
            # A_hat = self.gamma * (A_hat_x + A_hat_y)            # 加权融合水平和垂直方向
            
            # config = parse_args_and_config(self.args)
            # runner = Diffusion(self.args, config)
            # A_hat = runner.sample()
            # A_hat_upsampled = F.interpolate(A_hat, 
            #                                 size=A.shape[2:], 
            #                                 mode='bilinear', 
            #                                 align_corners=False
            #                             )

            # 综合数据保真项和先验项计算梯度更新量(公式6整体导数)
            # dR = (A + A_hat_upsampled)/(L*L + 4*self.gamma)               # 分母包含Hessian矩阵近似项
            # dR = (A)/(L*L + 4*self.gamma)
            # R_update = R - self.eta12[i,:] * dR                 # 梯度下降更新反射层
            
            # # 通过可学习的r_stage模块优化反射层(对应图2(b)的r_stage结构)
            # R_cat = torch.cat((R_update, Z_R), dim=1)           # 连接显式更新和隐式特征
            # R_cat_new = self.r_stage[i+1](R_cat)                # 网络模块处理融合特征
            # R = R_cat_new[:, :3, :, :]                          # 提取更新后的反射层
            # Z_R = R_cat_new[:, 3:, :, :]                        # 保留隐式特征供后续迭代
            L_ = F.interpolate(L.repeat(1, 3, 1, 1), 
                                size=(256, 256), 
                                mode='bilinear', 
                                align_corners=False
                                )
            x0, x1 = diffusion_prior(L_, df_model, betas, config)
            x0_hat = F.interpolate(x0, 
                                    size=L.shape[2:], 
                                    mode='bilinear', 
                                    align_corners=False
                                    )
            x1_hat = F.interpolate(x1,
                                    size=L.shape[2:],
                                mode='bilinear',
                                align_corners=False
                                )
        
            R =(x1_hat * L -input) * L + x0_hat
            # Z_R = R[:, 3:, :, :]  # 保留隐式特征供后续迭代使用
            
            ListR.append(R)  # 保存当前阶段的反射层结果

        return L0, R0, ListL, ListR  # 返回初始估计和各阶段优化结果
    

class Rnet(nn.Module):  #####
    def __init__(self, channels):#,args):
        super(Rnet, self).__init__()
        self.channels = channels
        self.relu = nn.ReLU(inplace=True)
        self.resm1 = nn.Sequential(
            nn.Conv2d(self.channels, self.channels, kernel_size=3, stride = 1, padding= 1, padding_mode='reflect'),
                                  nn.ReLU(inplace=True),
                                  nn.ReflectionPad2d(padding=(1, 1, 1, 1)),
                                  nn.Conv2d(self.channels, self.channels, kernel_size=3, stride = 1, padding= 0, dilation = 1),
                                   )
        self.resm2 = nn.Sequential(nn.Conv2d(self.channels, self.channels, kernel_size=3, stride = 1, padding= 1, padding_mode='reflect'),
                                  nn.ReLU(inplace=True),
                                  nn.ReflectionPad2d(padding=(1, 1, 1, 1)),
                                  nn.Conv2d(self.channels, self.channels, kernel_size=3, stride = 1, padding= 0, dilation = 1),
                                  )
        self.resm3 = nn.Sequential(nn.Conv2d(self.channels, self.channels, kernel_size=3, stride = 1, padding= 1, padding_mode='reflect'),
                                   nn.ReLU(inplace=True),
                                   nn.ReflectionPad2d(padding=(1, 1, 1, 1)),
                                   nn.Conv2d(self.channels, self.channels, kernel_size=3, stride=1, padding=0, dilation=1),
                                   )
        self.resm4 = nn.Sequential(nn.Conv2d(self.channels, self.channels, kernel_size=3, stride = 1, padding= 1, padding_mode='reflect'),
                                   nn.ReLU(inplace=True),
                                   nn.ReflectionPad2d(padding=(1, 1, 1, 1)),
                                   nn.Conv2d(self.channels, self.channels, kernel_size=3, stride=1, padding=0, dilation=1),
                                   )

#TODO: sigmoid of last stage?
    def forward(self, input):
        m1 = self.relu(input + self.resm1(input))
        m2 = self.relu(m1 + self.resm2(m1))
        m3 = self.relu(m2 + self.resm3(m2))
        m4 = self.relu(m3 + self.resm4(m3))

        return m4

class Lnet(nn.Module):
    def __init__(self,channels):
        super(Lnet, self).__init__()
        self.channels = channels
        self.conv1 = nn.Sequential(nn.Conv2d(in_channels=self.channels, out_channels=self.channels, kernel_size=3,
                                            padding_mode='reflect', padding=1),
                                  nn.LeakyReLU(inplace=True),
        )

        self.conv2 = nn.Sequential(nn.Conv2d(in_channels=self.channels+32, out_channels=self.channels, kernel_size=1),
                                   # nn.LeakyReLU(inplace=True),
                                   )

    def forward(self,input):
        conv1 = self.conv1(input)
        conv2 = torch.cat((conv1,input[:,2:,:,:]), dim=1)
        conv3 = self.conv2(conv2)
        out = F.sigmoid(conv3)
        return out















