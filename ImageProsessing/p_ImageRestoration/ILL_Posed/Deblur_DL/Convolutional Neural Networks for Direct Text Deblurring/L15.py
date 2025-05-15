import torch
import torch.nn as nn

class L15(nn.Module):
    def __init__(self):
        super(L15,self).__init__()
        self.conv1 = nn.Sequential(nn.Conv2d(3,128,kernel_size=19,padding=9),nn.ReLU(inplace=True))
        self.conv2 = nn.Sequential(nn.Conv2d(128,320,kernel_size=1,padding=0),nn.ReLU(inplace=True))
        self.conv3 = nn.Sequential(nn.Conv2d(320,320,kernel_size=1,padding=0),nn.ReLU(inplace=True))
        self.conv4 = nn.Sequential(nn.Conv2d(320,320,kernel_size=1,padding=0),nn.ReLU(inplace=True))
        self.conv5 = nn.Sequential(nn.Conv2d(320,128,kernel_size=1,padding=0),nn.ReLU(inplace=True))
        self.conv6 = nn.Sequential(nn.Conv2d(128,128,kernel_size=3,padding=1),nn.ReLU(inplace=True))
        self.conv7 = nn.Sequential(nn.Conv2d(128,512,kernel_size=1,padding=0),nn.ReLU(inplace=True))
        self.conv8 = nn.Sequential(nn.Conv2d(512,128,kernel_size=5,padding=2),nn.ReLU(inplace=True))
        self.conv9 = nn.Sequential(nn.Conv2d(128,128,kernel_size=5,padding=2),nn.ReLU(inplace=True))
        self.conv10 = nn.Sequential(nn.Conv2d(128,128,kernel_size=3,padding=1),nn.ReLU(inplace=True))
        self.conv11 = nn.Sequential(nn.Conv2d(128,128,kernel_size=5,padding=2),nn.ReLU(inplace=True))
        self.conv12 = nn.Sequential(nn.Conv2d(128,128,kernel_size=5,padding=2),nn.ReLU(inplace=True))
        self.conv13 = nn.Sequential(nn.Conv2d(128,256,kernel_size=1,padding=0),nn.ReLU(inplace=True))
        self.conv14 = nn.Sequential(nn.Conv2d(256,64,kernel_size=7,padding=3),nn.ReLU(inplace=True))
        self.conv15 = nn.Sequential(nn.Conv2d(64,3,kernel_size=7,padding=3),nn.Sigmoid())
        
    def forward(self,img):
        x1 = self.conv1(img)
        x2 = self.conv2(x1)
        x3 = self.conv3(x2)
        x4 = self.conv4(x3)
        x5 = self.conv5(x4)
        x6 = self.conv6(x5)
        x7 = self.conv7(x6)
        x8 = self.conv8(x7)
        x9 = self.conv9(x8)
        x10 = self.conv10(x9)
        x11 = self.conv11(x10)
        x12 = self.conv12(x11)
        x13 = self.conv13(x12)
        x14 = self.conv14(x13)
        x15 = self.conv15(x14)
        return x15