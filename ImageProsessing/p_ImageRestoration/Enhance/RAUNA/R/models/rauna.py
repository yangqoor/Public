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
    """完整的RAUNA模型：Retinex-Based Algorithm Unrolling and Adjustment"""
    def __init__(self, stages=17, fine_tune=True, channels=64):
        super(RAUNA, self).__init__()
        self.decnet = DecNet(stages=stages, channels=channels)
        self.adjnet = AdjNet(channels=channels)
        self.fine_tune = fine_tune
        
    def forward(self, x, alpha=0.5):
        # 分解阶段
        L, R = self.decnet(x)
        
        # 调整阶段
        enhanced, R_adj, L_adj = self.adjnet(x, R, L, alpha)
        
        return {
            'enhanced': enhanced,
            'reflectance': R,
            'illumination': L,
            'R_adj': R_adj,
            'L_adj': L_adj
        }
        
    def decompose_only(self, x):
        """仅执行分解步骤"""
        L, R = self.decnet(x)
        return L, R
    
    def enhance_with_decomposition(self, x, alpha=0.5):
        """使用给定的分解结果进行增强"""
        L, R = x
        enhanced, R_adj, L_adj = self.adjnet(R * L, R, L, alpha)
        return enhanced, R_adj, L_adj
    
    def fine_tune_model(self, x, steps=300, lr=1e-4):
        """自监督微调策略"""
        if not self.fine_tune:
            return self.forward(x)
            
        # 分解阶段
        with torch.no_grad():
            L, R = self.decnet(x)
        
        # 创建待优化参数
        L_opt = L.clone().detach().requires_grad_(True)
        R_opt = R.clone().detach().requires_grad_(True)
        alpha_opt = torch.tensor(0.5, requires_grad=True, device=x.device)
        
        # 优化器
        optimizer = torch.optim.Adam([L_opt, R_opt, alpha_opt], lr=lr)
        
        # 优化循环
        for _ in range(steps):
            # 前向传播
            enhanced = R_opt * L_opt
            
            # 计算损失：亮度、色彩、对比度等
            loss = torch.mean((enhanced - x)**2)  # 简化的MSE损失
            
            # 反向传播
            optimizer.zero_grad()
            loss.backward()
            optimizer.step()
            
            # 投影确保值在合理范围
            with torch.no_grad():
                L_opt.clamp_(0, 1)
                R_opt.clamp_(0, 1)
                alpha_opt.clamp_(0, 1)
        
        # 使用优化后的参数进行最终增强
        enhanced, R_adj, L_adj = self.adjnet(x, R_opt, L_opt, alpha_opt)
        
        return {
            'enhanced': enhanced,
            'reflectance': R_opt,
            'illumination': L_opt,
            'R_adj': R_adj,
            'L_adj': L_adj
        } 