# -*- coding: utf-8 -*-
"""
Created on Mon Sep  2 18:17:29 2019

@author: JIAN
"""
import torch
class CNNLSTM(torch.nn.Module):
    """
    The codes implement the CNN model proposed in the paper "Subject-Independent Drowsiness Recognition from Single-Channel EEG with an Interpretable CNN-LSTM model".
    The network is designed to classify 1D drowsy and alert EEG signals for the purposed of driver drowsiness recognition.
      
    """
    def __init__(self):
        super(CNNLSTM, self).__init__()
        self.feature=32
        self.padding= torch.nn.ReplicationPad2d((31,32,0,0))
        self.conv = torch.nn.Conv2d(1,self.feature,(1,64))#,padding=(0,32),padding_mode='replicate')     
        self.batch = Batchlayer(self.feature)          
        self.avgpool = torch.nn.AvgPool2d((1,8))
        self.fc = torch.nn.Linear(32, 2)        
        self.softmax=torch.nn.LogSoftmax(dim=1)
        self.softmax1=torch.nn.Softmax(dim=1)        
        self.lstm=torch.nn.LSTM(32, 2)
        
    def forward(self, source): 
        source = self.padding(source)
        source = self.conv(source)
        source = self.batch(source)
        
        source = torch.nn.ELU()(source) 
        source=self.avgpool(source)        
        source =source.squeeze()
        source=source.permute(2, 0, 1)
        source = self.lstm(source)
        source=source[1][0].squeeze()
        source = self.softmax(source)   

        return source 

"""
We use the batch normalization layer implemented by ourselves for this model instead using the one provided by the Pytorch library.
In this implementation, we do not use momentum and initialize the gamma and beta values in the range (-0.1,0.1). 
We have got slightly increased accuracy using our implementation of the batch normalization layer.
"""
def normalizelayer(data):
    eps=1e-05
    a_mean=data-torch.mean(data, [0,2,3],True).expand(int(data.size(0)), int(data.size(1)), int(data.size(2)),int(data.size(3)))
    b=torch.div(a_mean,torch.sqrt(torch.mean((a_mean)**2, [0,2,3],True)+eps).expand(int(data.size(0)), int(data.size(1)), int(data.size(2)),int(data.size(3))))
    
    return b

class Batchlayer(torch.nn.Module):
    def __init__(self, dim):
        super(Batchlayer, self).__init__()
        self.gamma=torch.nn.Parameter(torch.Tensor(1,dim,1,1))
        self.beta=torch.nn.Parameter(torch.Tensor(1,dim,1,1))
        self.gamma.data.uniform_(-0.1, 0.1)
        self.beta.data.uniform_(-0.1, 0.1)
        
    def forward(self, input):
        data=normalizelayer(input)
        gammamatrix=self.gamma.expand(int(data.size(0)), int(data.size(1)), int(data.size(2)),int(data.size(3)))
        betamatrix = self.beta.expand(int(data.size(0)), int(data.size(1)), int(data.size(2)),int(data.size(3)))
        
        return data*gammamatrix+betamatrix
