import torch
import torch.nn as nn
from .common import *
import torch.nn.functional as F


# def fcn(num_input_channels=200, num_output_channels=1, num_hidden=1000):
#
#
#     model = nn.Sequential()
#     model.add(nn.Linear(num_input_channels, num_hidden,bias=True))
#     model.add(nn.ReLU6())
# #
#     model.add(nn.Linear(num_hidden, num_output_channels))
# #    model.add(nn.ReLU())
# #     model.add(nn.Softmax())
# #
#     return model


class fcn(nn.Module):
    def __init__(self, num_input_channels=200, num_output_channels=1, num_hidden=1000):
        super(fcn, self).__init__()
        self.linear = nn.Sequential(nn.Linear(num_input_channels, num_hidden, bias=True),
                                    nn.LeakyReLU(0.2, inplace=True),
                                    nn.Linear(num_hidden, num_output_channels))

    def forward(self, x):
        x = self.linear(x)
        # length = x.shape[0]
        # x = x.view()

        return x


class fcn_softmax(nn.Module):
    def __init__(self, num_input_channels=200, num_output_channels=1, num_hidden=1000):
        super(fcn_softmax, self).__init__()
        self.linear = nn.Sequential(nn.Linear(num_input_channels, num_hidden, bias=True),
                                    nn.LeakyReLU(0.2, inplace=True),
                                    nn.Linear(num_hidden, num_output_channels))

    def forward(self, x):
        x = self.linear(x)

        x = F.softmax(x)

        return x



class fcn_relu6(nn.Module):
    def __init__(self, num_input_channels=200, num_output_channels=1, num_hidden=1000):
        super(fcn_relu6, self).__init__()
        self.linear = nn.Sequential(nn.Linear(num_input_channels, num_hidden, bias=True),
                                    nn.ReLU6(inplace=True),
                                    nn.Linear(num_hidden, num_output_channels))

    def forward(self, x):
        x = self.linear(x)

        x = F.softmax(x)

        return x

class fcn_sigmoid(nn.Module):
    def __init__(self, num_input_channels=200, num_output_channels=1, num_hidden=1000):
        super(fcn_sigmoid, self).__init__()
        self.linear = nn.Sequential(nn.Linear(num_input_channels, num_hidden, bias=True),
                                    nn.ReLU6(inplace=True),
                                    nn.Linear(num_hidden, num_output_channels))

    def forward(self, x):
        x = self.linear(x)

        x = F.sigmoid(x)

        return x



