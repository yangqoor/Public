import sys
sys.path.append('/code/EFNet-main/EFNet-main/')
from basicsr.models.fac.kernelconv2d.KernelConv2D import KernelConv2D
import torch


model = KernelConv2D(3)

x = torch.zeros((4,1,3,3)).cuda()

x[:,0,1,1] = 1.
# x[0,0,2,2] = 1.

kernel = torch.range(0,8).cuda().reshape(1,9,1,1)

kernel = kernel.repeat(4,1,3,3)
# kernel[1:4,...] = 0.

print(model(x, kernel))
