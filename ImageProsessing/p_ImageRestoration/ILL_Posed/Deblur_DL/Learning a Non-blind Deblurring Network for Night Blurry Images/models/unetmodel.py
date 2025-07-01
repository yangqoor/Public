from .unetparts import *


class UNet(nn.Module):
    def __init__(self, n_channels, outchannel, bilinear=True):
        super(UNet, self).__init__()
        self.n_channels = n_channels
        self.n_classes = outchannel
        self.bilinear = bilinear
        self.inc = DoubleConv(n_channels, 8)
        self.down1 = Down(8, 16)
        self.down2 = Down(16, 32)
        self.down3 = Down(32, 32)
        self.up1 = Up(64, 16, bilinear)
        self.up2 = Up(32, 8, bilinear)
        self.up3 = Up(16, 8, bilinear)
        self.outc = OutConv(8, outchannel)

    def forward(self, x):
        x1 = self.inc(x)
        x2 = self.down1(x1)
        x3 = self.down2(x2)
        x4 = self.down3(x3)
        x = self.up1(x4, x3)
        x = self.up2(x, x2)
        x = self.up3(x, x1)
        output = self.outc(x)
        return output