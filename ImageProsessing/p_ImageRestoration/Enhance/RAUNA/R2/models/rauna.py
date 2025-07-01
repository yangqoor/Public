import torch
import torch.nn as nn
import torch.nn.functional as F

class ResBlock(nn.Module):
    def __init__(self, channels):
        super(ResBlock, self).__init__()
        self.conv1 = nn.Conv2d(channels, channels, kernel_size=3, padding=1)
        self.relu = nn.ReLU(inplace=True)
        self.conv2 = nn.Conv2d(channels, channels, kernel_size=3, padding=1)
        
    def forward(self, x):
        residual = x
        out = self.conv1(x)
        out = self.relu(out)
        out = self.conv2(out)
        out += residual
        return out

class AlphaBlock(nn.Module):
    def __init__(self, channels):
        super(AlphaBlock, self).__init__()
        self.conv = nn.Conv2d(channels, channels, kernel_size=1)
        self.sigmoid = nn.Sigmoid()
        
    def forward(self, x):
        weight = self.conv(x)
        weight = self.sigmoid(weight)
        return x * weight

class DecNetStage(nn.Module):
    """单个算法展开阶段"""
    def __init__(self, channels=64):
        super(DecNetStage, self).__init__()
        # 初始阶段 - 从RGB图像提取
        self.initial_L_branch = nn.Sequential(
            nn.Conv2d(3, channels, kernel_size=3, padding=1),
            ResBlock(channels),
            ResBlock(channels),
            nn.Conv2d(channels, 1, kernel_size=3, padding=1)
        )
        
        self.initial_R_branch = nn.Sequential(
            nn.Conv2d(3, channels, kernel_size=3, padding=1),
            ResBlock(channels),
            ResBlock(channels),
            nn.Conv2d(channels, 3, kernel_size=3, padding=1)
        )
        
        # 迭代阶段 - 接收前一阶段结果并改进
        # L分支: 输入包括原始图像(3) + 前一阶段照明层(1) + 前一阶段反射层(3) = 7通道
        self.L_branch = nn.Sequential(
            nn.Conv2d(7, channels, kernel_size=3, padding=1),
            ResBlock(channels),
            nn.Conv2d(channels, 1, kernel_size=3, padding=1)
        )
        
        # R分支: 输入包括原始图像(3) + 前一阶段照明层(1) + 前一阶段反射层(3) = 7通道
        self.R_branch = nn.Sequential(
            nn.Conv2d(7, channels, kernel_size=3, padding=1),
            ResBlock(channels),
            nn.Conv2d(channels, 3, kernel_size=3, padding=1)
        )
        
        # 结构先验模块
        self.structure_prior = nn.Sequential(
            nn.Conv2d(3, channels, kernel_size=3, padding=1),
            ResBlock(channels),
            nn.Conv2d(channels, 3, kernel_size=3, padding=1)
        )
        
    def forward(self, input_img, prev_L=None, prev_R=None):
        if prev_L is None or prev_R is None:
            # 第一阶段
            L = self.initial_L_branch(input_img)
            R = self.initial_R_branch(input_img)
        else:
            # 算法展开，利用先前阶段的结果
            L_input = torch.cat([input_img, prev_L, prev_R], dim=1)
            R_input = torch.cat([input_img, prev_L, prev_R], dim=1)
            
            L = prev_L + self.L_branch(L_input)
            
            # 计算结构先验
            G = self.structure_prior(prev_R)
            
            R = prev_R + self.R_branch(R_input) + 0.1 * G
            
        return L, R

class DecNet(nn.Module):
    """基于算法展开的分解网络"""
    def __init__(self, stages=17, channels=64):
        super(DecNet, self).__init__()
        self.stages = nn.ModuleList([DecNetStage(channels=channels) for _ in range(stages)])
        
    def forward(self, x):
        L, R = None, None
        
        for stage in self.stages:
            L, R = stage(x, L, R)
            
        return L, R

class LBSModule(nn.Module):
    """局部亮度敏感度模块"""
    def __init__(self, channels=64):
        super(LBSModule, self).__init__()
        self.conv1 = nn.Conv2d(1, channels, kernel_size=3, padding=1)
        self.relu = nn.ReLU(inplace=True)
        self.conv2 = nn.Conv2d(channels, 1, kernel_size=3, padding=1)
        
    def forward(self, low_light, illumination):
        # 转为灰度并计算差异
        if low_light.size(1) == 3:
            gray_low = 0.299 * low_light[:, 0:1] + 0.587 * low_light[:, 1:2] + 0.114 * low_light[:, 2:3]
        else:
            gray_low = low_light
            
        diff = gray_low - illumination
        
        out = self.conv1(diff)
        out = self.relu(out)
        out = self.conv2(out)
        
        return out

class AdjNet(nn.Module):
    """调整网络"""
    def __init__(self, channels=64):
        super(AdjNet, self).__init__()
        # 照明层调整网络 L-AdjNet
        self.L_adjnet = nn.Sequential(
            nn.Conv2d(1, channels, kernel_size=3, padding=1),
            ResBlock(channels),
            nn.Conv2d(channels, 1, kernel_size=3, padding=1)
        )
        
        # 反射层调整网络 R-AdjNet
        self.R_adjnet = nn.Sequential(
            nn.Conv2d(4, channels, kernel_size=3, padding=1),  # 3通道反射层 + 1通道LBS特征
            ResBlock(channels),
            ResBlock(channels),
            nn.Conv2d(channels, 3, kernel_size=3, padding=1)
        )
        
        # LBS模块
        self.lbs = LBSModule(channels=channels)
        
    def forward(self, low_light, reflectance, illumination, alpha=0.5):
        # 全局亮度参数作用于照明层
        L_adj_input = illumination
        L_adj = self.L_adjnet(L_adj_input)
        L_adj_1 = F.relu(L_adj_input + alpha * L_adj)  # 第一个ReLU层
        L_adj_2 = F.relu(L_adj_1 + alpha * L_adj)      # 第二个ReLU层
        
        # LBS特征用于反射层调整
        lbs_feature = self.lbs(low_light, illumination)
        
        # 连接反射层和LBS特征
        R_adj_input = torch.cat([reflectance, lbs_feature], dim=1)
        R_adj = self.R_adjnet(R_adj_input)
        
        # 最终结果是调整后的反射层和照明层的重组
        enhanced = R_adj * L_adj_2
        
        return enhanced, R_adj, L_adj_2

class RAUNA(nn.Module):
    """RAUNA - Retinex Adjustment through Unfolding Network Architecture"""
    def __init__(self, stages=17, channels=64):
        super(RAUNA, self).__init__()
        self.stages = stages
        self.channels = channels
        
        # 分解网络 - DecNet 使用算法展开结构
        self.decnet = DecNet(stages=stages, channels=channels)
        
        # 调整网络 - AdjNet 用于调整分解结果以获得更好的增强效果
        self.adjnet = AdjNet(channels=channels)
        
        # 是否使用微调
        self.fine_tune = False
        
    def forward(self, x, alpha=0.5):
        """前向传播 - 完整的增强过程"""
        # 第一阶段：分解
        L, R = self.decnet(x)
        
        # 确保L和R在合理范围内 (避免漆黑一片的问题)
        L = torch.clamp(L, 0.01, 1.0)  # 照明层不应该有0值
        R = torch.clamp(R, 0.01, 1.0)  # 反射层也应保持正值

        # 第二阶段：调整并增强
        enhanced, R_adj, L_adj = self.adjnet(x, R, L, alpha)
        
        # 确保增强后的图像亮度合理 (解决输出漆黑一片的问题)
        # 计算输入和输出的平均亮度
        if x.dim() == 4:  # 批处理情况
            input_brightness = torch.mean(x, dim=[1, 2, 3], keepdim=True)
            output_brightness = torch.mean(enhanced, dim=[1, 2, 3], keepdim=True)
        else:  # 单张图像
            input_brightness = torch.mean(x)
            output_brightness = torch.mean(enhanced)
        
        # 如果输出亮度低于输入，进行额外的亮度提升
        brightness_ratio = torch.where(
            output_brightness < input_brightness,
            input_brightness / (output_brightness + 1e-6),
            torch.ones_like(output_brightness)
        )
        # 应用亮度提升，确保输出不会比输入更暗
        enhanced = torch.min(
            enhanced * brightness_ratio * 1.2,  # 额外提高20%亮度
            torch.ones_like(enhanced)  # 确保不超过1
        )
        
        return {
            'enhanced': enhanced,
            'reflectance': R,
            'illumination': L,
            'R_adj': R_adj,
            'L_adj': L_adj
        }

    def decompose_only(self, x):
        """仅执行分解阶段"""
        L, R = self.decnet(x)
        # 确保值在合理范围内
        L = torch.clamp(L, 0.01, 1.0)
        R = torch.clamp(R, 0.01, 1.0)
        return L, R

    def enhance_with_decomposition(self, decomposition, alpha=0.5):
        """使用给定的分解结果进行增强"""
        L, R = decomposition
        # 确保照明层和反射层在合理范围内
        L = torch.clamp(L, 0.01, 1.0)
        R = torch.clamp(R, 0.01, 1.0)
        
        # 计算原始低光图像 (用于AdjNet输入)
        x = R * L
        
        # 使用调整网络增强图像
        enhanced, R_adj, L_adj = self.adjnet(x, R, L, alpha)
        
        # 确保输出亮度合理
        output_brightness = torch.mean(enhanced)
        input_brightness = torch.mean(x)
        
        # 如果输出亮度低于输入，进行额外的亮度提升
        if output_brightness < input_brightness:
            brightness_ratio = input_brightness / (output_brightness + 1e-6)
            enhanced = torch.clamp(enhanced * brightness_ratio * 1.2, 0.0, 1.0)
            
        return enhanced, R_adj, L_adj