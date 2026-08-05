import paddle
import paddle.nn as nn
import paddle.nn.functional as F

class HedNetwork(nn.Layer):
    def __init__(self, weight_path=None):
        super().__init__()

        # 网络结构定义
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

        # 自动加载权重
        if weight_path is not None:
            self.load_paddle_weights(weight_path)

    def load_paddle_weights(self, weight_path):
        """加载PaddlePaddle格式的权重文件"""
        try:
            # 使用paddle.load加载权重
            state_dict = paddle.load(weight_path)
            
            # 使用set_state_dict加载权重到模型
            self.set_state_dict(state_dict)
            print(f"✅ Paddle权重从 {weight_path} 加载成功！")
            
        except Exception as e:
            print(f"❌ 权重加载失败: {e}")
            print("将使用随机初始化的权重")

    def forward(self, tenInput):
        # 前向传播逻辑保持不变
        tenInput = tenInput * 255.0
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

        tenScoreOne = F.interpolate(tenScoreOne, size=(tenInput.shape[2], tenInput.shape[3]), mode='bilinear', align_corners=False)
        tenScoreTwo = F.interpolate(tenScoreTwo, size=(tenInput.shape[2], tenInput.shape[3]), mode='bilinear', align_corners=False)
        tenScoreThr = F.interpolate(tenScoreThr, size=(tenInput.shape[2], tenInput.shape[3]), mode='bilinear', align_corners=False)
        tenScoreFou = F.interpolate(tenScoreFou, size=(tenInput.shape[2], tenInput.shape[3]), mode='bilinear', align_corners=False)
        tenScoreFiv = F.interpolate(tenScoreFiv, size=(tenInput.shape[2], tenInput.shape[3]), mode='bilinear', align_corners=False)

        return self.netCombine(paddle.concat([tenScoreOne, tenScoreTwo, tenScoreThr, tenScoreFou, tenScoreFiv], 1))
    
netNetwork = None

def estimate(tenInput):
    global netNetwork

    if netNetwork is None:
        # 初始化网络并加载权重
        netNetwork = HedNetwork(weight_path='network-bsds500.pdparams')
        netNetwork.eval()  # 设置为评估模式
        print("模型初始化完成，权重已加载")

    intWidth = tenInput.shape[3]
    intHeight = tenInput.shape[2]

    # 尺寸检查（可选，根据需要注释掉）
    # assert(intWidth == 480)
    # assert(intHeight == 320)

    # 使用no_grad避免梯度计算
    with paddle.no_grad():
        output = netNetwork(tenInput)
    
    return output[0, 0, :, :]  # 返回第一个batch的第一个通道


import getopt
import numpy
import PIL
import PIL.Image
import sys
import paddle
import paddle.nn as nn
import paddle.nn.functional as F

##########################################################
# 上面定义的Network类和estimate函数放在这里
##########################################################

def main():
    # 参数解析
    # args_strIn = './images/sample.png'
    args_strIn = './images/t1_2.jpg'
    args_strOut = './out2.png'

    # 简单的参数解析
    args = sys.argv[1:]
    for i in range(len(args)):
        if args[i] == '--in' and i+1 < len(args):
            args_strIn = args[i+1]
        elif args[i] == '--out' and i+1 < len(args):
            args_strOut = args[i+1]

    try:
        # 读取和预处理图像
        pilImage = PIL.Image.open(args_strIn)
        
        # 转换图像为numpy数组并进行预处理
        numpyImage = numpy.array(pilImage)
        
        # 如果是RGBA图像，转换为RGB
        if numpyImage.shape[-1] == 4:
            numpyImage = numpyImage[:, :, :3]
        
        # RGB转BGR并调整维度
        numpyImage = numpyImage[:, :, ::-1]  # RGB转BGR
        numpyImage = numpyImage.transpose(2, 0, 1).astype(numpy.float32) * (1.0 / 255.0)
        
        # 转换为Paddle Tensor
        tenInput = paddle.to_tensor(numpyImage[numpy.newaxis, :, :, :])  # 增加batch维度

        print(f"处理图像: {args_strIn}, 尺寸: {numpyImage.shape}")

        # 进行边缘检测
        tenOutput = estimate(tenInput)

        # 后处理：转换为PIL图像并保存
        numpyOutput = tenOutput.numpy()
        numpyOutput = numpy.clip(numpyOutput, 0.0, 1.0)  # 裁剪到[0,1]
        numpyOutput = (numpyOutput * 255.0).astype(numpy.uint8)
        
        # 保存结果
        PIL.Image.fromarray(numpyOutput).save(args_strOut)
        print(f"✅ 边缘检测结果已保存到: {args_strOut}")

    except Exception as e:
        print(f"❌ 处理失败: {e}")

if __name__ == '__main__':
    main()