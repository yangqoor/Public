import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as f
# from dropblock import DropBlock2D
# from networks.skip import skip
# from sparsemax import Sparsemax

class Normalizer(nn.Module):
    def __init__(self,p=2):
        super(Normalizer, self).__init__()
        self.p = p
        self.out = None
    def forward(self,input):
        input = torch.squeeze(input)
        input2 = torch.exp(input)
        self.out = f.normalize(input2,p=self.p,dim=0)
        return self.out

class Mysoftmax(nn.Module):
    def __init__(self):
        super(Mysoftmax,self).__init__()
        self.sx = None
        self.sy = None
        self.n_grid = None
        # self.sparsemax = Sparsemax()
    def forward(self,input):
        self.n_grid = input.size(1)
        self.sx = input.size(2)
        self.sy = input.size(3)
        # print(self.n_grid)
        input = input.view(1,self.n_grid,-1)
        # input = torch.squeeze(input)

        # outputt1 = torch.exp(input)
        # output = f.normalize(outputt1, p=1, dim=0)
        # outputt1 = torch.pow(input,2)
        # output = outputt1/torch.sum(outputt1)
        output = f.softmax(input,dim=-1)
        # output = self.sparsemax(input)
        output = output.view(1,self.n_grid,self.sx,self.sy)
        return output
class Mysoftmax2(nn.Module):
    def __init__(self):
        super(Mysoftmax2,self).__init__()
        self.sx = None
        self.sy = None
        self.n_grid = None
        # self.sparsemax = Sparsemax()
    def forward(self,input):
        self.n_grid = input.size(1)
        self.sx = input.size(2)
        self.sy = input.size(3)
        # print(self.n_grid)
        input = input.reshape(1,self.n_grid,-1)
        # input = torch.squeeze(input)

        # outputt1 = torch.exp(input)
        # output = f.normalize(outputt1, p=1, dim=0)
        # outputt1 = torch.pow(input,2)
        # output = outputt1/torch.sum(outputt1)
        output = f.softmax(input,dim=-1)
        # output = self.sparsemax(input)
        output = output.view(1,self.n_grid,self.sx,self.sy)
        return output

class myExp(nn.Module):
    def __init__(self):
        super(myExp,self).__init__()
    def forward(self,input):
        return torch.exp(input)

class Mysigmoid(nn.Module):
    def __init__(self):
        super(Mysigmoid,self).__init__()
    def forward(self,input):
        return torch.exp(input)
class Mydropout(nn.Module):
    def __init__(self):
        super(Mydropout,self).__init__()
    def forward(self,input):
        drop_block = DropBlock2D(block_size=3,drop_prob=0.3)
        return drop_block(input)

class ScaleLayer(nn.Module):
   def __init__(self, value=1):
       super(ScaleLayer,self).__init__()
       self.scale = value
   def forward(self, input):
       return input * self.scale



