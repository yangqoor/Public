#!/usr/bin/env python

import getopt
import numpy
import PIL
import PIL.Image
import sys
import paddle
import paddle.nn as nn
import paddle.nn.functional as F
import numpy as np

##########################################################

class Network(nn.Layer):
    def __init__(self):
        super().__init__()

        self.netVggOne = nn.Sequential(
            nn.Conv2D(in_channels=3, out_channels=64, kernel_size=3, stride=1, padding=1),
            nn.ReLU(),
            nn.Conv2D(in_channels=64, out_channels=64, kernel_size=3, stride=1, padding=1),
            nn.ReLU()
        )

        self.netVggTwo = nn.Sequential(
            nn.MaxPool2D(kernel_size=2, stride=2),
            nn.Conv2D(in_channels=64, out_channels=128, kernel_size=3, stride=1, padding=1),
            nn.ReLU(),
            nn.Conv2D(in_channels=128, out_channels=128, kernel_size=3, stride=1, padding=1),
            nn.ReLU()
        )

        self.netVggThr = nn.Sequential(
            nn.MaxPool2D(kernel_size=2, stride=2),
            nn.Conv2D(in_channels=128, out_channels=256, kernel_size=3, stride=1, padding=1),
            nn.ReLU(),
            nn.Conv2D(in_channels=256, out_channels=256, kernel_size=3, stride=1, padding=1),
            nn.ReLU(),
            nn.Conv2D(in_channels=256, out_channels=256, kernel_size=3, stride=1, padding=1),
            nn.ReLU()
        )

        self.netVggFou = nn.Sequential(
            nn.MaxPool2D(kernel_size=2, stride=2),
            nn.Conv2D(in_channels=256, out_channels=512, kernel_size=3, stride=1, padding=1),
            nn.ReLU(),
            nn.Conv2D(in_channels=512, out_channels=512, kernel_size=3, stride=1, padding=1),
            nn.ReLU(),
            nn.Conv2D(in_channels=512, out_channels=512, kernel_size=3, stride=1, padding=1),
            nn.ReLU()
        )

        self.netVggFiv = nn.Sequential(
            nn.MaxPool2D(kernel_size=2, stride=2),
            nn.Conv2D(in_channels=512, out_channels=512, kernel_size=3, stride=1, padding=1),
            nn.ReLU(),
            nn.Conv2D(in_channels=512, out_channels=512, kernel_size=3, stride=1, padding=1),
            nn.ReLU(),
            nn.Conv2D(in_channels=512, out_channels=512, kernel_size=3, stride=1, padding=1),
            nn.ReLU()
        )

        self.netScoreOne = nn.Conv2D(in_channels=64, out_channels=1, kernel_size=1, stride=1, padding=0)
        self.netScoreTwo = nn.Conv2D(in_channels=128, out_channels=1, kernel_size=1, stride=1, padding=0)
        self.netScoreThr = nn.Conv2D(in_channels=256, out_channels=1, kernel_size=1, stride=1, padding=0)
        self.netScoreFou = nn.Conv2D(in_channels=512, out_channels=1, kernel_size=1, stride=1, padding=0)
        self.netScoreFiv = nn.Conv2D(in_channels=512, out_channels=1, kernel_size=1, stride=1, padding=0)

        self.netCombine = nn.Sequential(
            nn.Conv2D(in_channels=5, out_channels=1, kernel_size=1, stride=1, padding=0),
            nn.Sigmoid()
        )

    def forward(self, tenInput):
        tenInput = tenInput * 255.0
        # PaddlePaddle的均值张量处理
        mean_tensor = paddle.to_tensor([104.00698793, 116.66876762, 122.67891434], dtype=tenInput.dtype)
        mean_tensor = mean_tensor.reshape([1, 3, 1, 1])
        tenInput = tenInput - mean_tensor

        tenVggOne = self.netVggOne(tenInput)
        tenVggTwo = self.netVggTwo(tenVggOne)
        tenVggThr = self.netVggThr(tenVggTwo)
        tenVggFou = self.netVggFou(tenVggThr)
        tenVggFiv = self.netVggFiv(tenVggFou)

        tenScoreOne = self.netScoreOne(tenVggOne)
        tenScoreTwo = self.netScoreTwo(tenVggTwo)
        tenScoreThr = self.netScoreThr(tenVggThr)
        tenScoreFou = self.netScoreFou(tenVggFou)
        tenScoreFiv = self.netScoreFiv(tenVggFiv)

        # PaddlePaddle的插值函数
        tenScoreOne = F.interpolate(tenScoreOne, size=(tenInput.shape[2], tenInput.shape[3]), mode='bilinear', align_corners=False)
        tenScoreTwo = F.interpolate(tenScoreTwo, size=(tenInput.shape[2], tenInput.shape[3]), mode='bilinear', align_corners=False)
        tenScoreThr = F.interpolate(tenScoreThr, size=(tenInput.shape[2], tenInput.shape[3]), mode='bilinear', align_corners=False)
        tenScoreFou = F.interpolate(tenScoreFou, size=(tenInput.shape[2], tenInput.shape[3]), mode='bilinear', align_corners=False)
        tenScoreFiv = F.interpolate(tenScoreFiv, size=(tenInput.shape[2], tenInput.shape[3]), mode='bilinear', align_corners=False)

        return self.netCombine(paddle.concat([tenScoreOne, tenScoreTwo, tenScoreThr, tenScoreFou, tenScoreFiv], 1))
    
    def load_pytorch_weights(self, pytorch_weights_path):
        """
        加载PyTorch预训练权重并转换为Paddle格式
        """
        try:
            import torch
            # 加载PyTorch权重
            torch_weights = torch.load(pytorch_weights_path, map_location='cpu')
            
            # 权重名称映射转换
            paddle_weights = {}
            for key, value in torch_weights.items():
                # 替换模块名称
                new_key = key.replace('module', 'net')
                
                # 转换权重格式：PyTorch的conv权重是 (out_c, in_c, h, w)，Paddle是 (out_c, in_c, h, w) 但需要转置检查
                if value.ndim == 4:  # 卷积权重
                    # PyTorch: (out_c, in_c, h, w) -> Paddle: (out_c, in_c, h, w) 格式相同
                    paddle_value = value.detach().numpy()
                elif value.ndim == 1:  # 偏置
                    paddle_value = value.detach().numpy()
                else:
                    paddle_value = value.detach().numpy()
                
                paddle_weights[new_key] = paddle_value
            
            # 加载到Paddle模型
            self.set_state_dict(paddle_weights)
            print("PyTorch权重转换并加载成功！")
            
        except Exception as e:
            print(f"权重加载失败: {e}")
            print("将使用随机初始化的权重")

# end

netNetwork = None

##########################################################

def estimate(tenInput):
    global netNetwork

    if netNetwork is None:
        netNetwork = Network()
        # 加载预训练权重
        netNetwork.load_pytorch_weights('network-bsds500.pytorch')
        netNetwork.eval()
    # end

    intWidth = tenInput.shape[3]  # Paddle格式: [N, C, H, W]
    intHeight = tenInput.shape[2]

    assert(intWidth == 480) # 确保输入尺寸正确
    assert(intHeight == 320) # 确保输入尺寸正确

    # 使用no_grad避免梯度计算
    with paddle.no_grad():
        output = netNetwork(tenInput)
    
    return output[0, 0, :, :]  # 返回第一个batch的第一个通道
# end

##########################################################

def main():
    # 参数解析
    args_strModel = 'bsds500'  # 只有'bsds500'可选
    args_strIn = './images/sample.png'
    args_strOut = './out.png'

    # 简单的参数解析（替代getopt）
    args = sys.argv[1:]
    for i in range(len(args)):
        if args[i] == '--model' and i+1 < len(args):
            args_strModel = args[i+1]
        elif args[i] == '--in' and i+1 < len(args):
            args_strIn = args[i+1]
        elif args[i] == '--out' and i+1 < len(args):
            args_strOut = args[i+1]

    # 读取和预处理图像
    pilImage = PIL.Image.open(args_strIn)
    
    # 转换图像为numpy数组并进行预处理
    numpyImage = numpy.array(pilImage)[:, :, ::-1]  # RGB转BGR
    numpyImage = numpyImage.transpose(2, 0, 1).astype(numpy.float32) * (1.0 / 255.0)
    
    # 转换为Paddle Tensor
    tenInput = paddle.to_tensor(numpyImage[numpy.newaxis, :, :, :])  # 增加batch维度

    # 进行边缘检测
    tenOutput = estimate(tenInput)

    # 后处理：转换为PIL图像并保存
    numpyOutput = tenOutput.numpy()
    numpyOutput = numpy.clip(numpyOutput, 0.0, 1.0)  # 裁剪到[0,1]
    numpyOutput = (numpyOutput * 255.0).astype(numpy.uint8)
    
    # 保存结果
    PIL.Image.fromarray(numpyOutput).save(args_strOut)
    print(f"边缘检测结果已保存到: {args_strOut}")

if __name__ == '__main__':
    main()