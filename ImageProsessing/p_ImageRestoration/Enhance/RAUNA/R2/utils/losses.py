import torch
import torch.nn as nn
import torch.nn.functional as F
import torchvision.models as models

class VGGPerceptualLoss(nn.Module):
    """VGG感知损失"""
    def __init__(self):
        super(VGGPerceptualLoss, self).__init__()
        vgg = models.vgg16(pretrained=True).features[:16]
        self.vgg = nn.Sequential()
        for i in range(16):
            self.vgg.add_module(str(i), vgg[i])
        for p in self.vgg.parameters():
            p.requires_grad = False
        self.vgg.eval()
            
    def forward(self, input, target):
        """计算特征空间的MSE损失"""
        input_features = self.vgg(input)
        target_features = self.vgg(target)
        return F.mse_loss(input_features, target_features)

class ColorLoss(nn.Module):
    """颜色损失"""
    def __init__(self):
        super(ColorLoss, self).__init__()
        
    def forward(self, x, y):
        # 计算RGB通道间的角度
        batch_size = x.size(0)
        x_norm = F.normalize(x.view(batch_size, 3, -1), dim=2)
        y_norm = F.normalize(y.view(batch_size, 3, -1), dim=2)
        
        # 计算每个像素的RGB向量之间的角度
        cos_angle = torch.sum(x_norm * y_norm, dim=1)
        loss = torch.mean(1 - cos_angle)
        return loss

class StructuralLoss(nn.Module):
    """结构相似性损失"""
    def __init__(self, window_size=11):
        super(StructuralLoss, self).__init__()
        self.window_size = window_size
        self.register_buffer('window', self._create_window(window_size))
        
    def _create_window(self, window_size):
        # 创建高斯窗口 - 修复版本
        sigma = 1.5 * window_size / 11
        # 创建坐标
        coords = torch.arange(window_size, dtype=torch.float)
        # 计算高斯值
        coords = coords - window_size // 2
        gauss = torch.exp(-(coords ** 2) / (2 * sigma ** 2))
        gauss = gauss / gauss.sum()
        
        # 创建2D窗口
        _1D_window = gauss.unsqueeze(1)
        _2D_window = _1D_window.mm(_1D_window.t()).float().unsqueeze(0).unsqueeze(0)
        return _2D_window
        
    def forward(self, x, y):
        # 计算SSIM
        C1 = 0.01**2
        C2 = 0.03**2
        
        # 灰度转换
        if x.size(1) == 3:
            x = 0.299 * x[:, 0:1] + 0.587 * x[:, 1:2] + 0.114 * x[:, 2:3]
            y = 0.299 * y[:, 0:1] + 0.587 * y[:, 1:2] + 0.114 * y[:, 2:3]
        
        # 使用高斯窗口平滑
        window = self.window.expand(x.size(1), 1, self.window_size, self.window_size)
        mu_x = F.conv2d(x, window, padding=self.window_size//2, groups=x.size(1))
        mu_y = F.conv2d(y, window, padding=self.window_size//2, groups=y.size(1))
        
        mu_x_sq = mu_x.pow(2)
        mu_y_sq = mu_y.pow(2)
        mu_xy = mu_x * mu_y
        
        sigma_x_sq = F.conv2d(x * x, window, padding=self.window_size//2, groups=x.size(1)) - mu_x_sq
        sigma_y_sq = F.conv2d(y * y, window, padding=self.window_size//2, groups=y.size(1)) - mu_y_sq
        sigma_xy = F.conv2d(x * y, window, padding=self.window_size//2, groups=x.size(1)) - mu_xy
        
        SSIM = ((2 * mu_xy + C1) * (2 * sigma_xy + C2)) / ((mu_x_sq + mu_y_sq + C1) * (sigma_x_sq + sigma_y_sq + C2))
        return 1 - SSIM.mean()

class DecNetLoss(nn.Module):
    """DecNet的损失函数"""
    def __init__(self):
        super(DecNetLoss, self).__init__()
        
    def reflectance_consistency_loss(self, R_low, R_normal):
        """反射层一致性损失"""
        return F.mse_loss(R_low, R_normal)
    
    def illumination_smoothness_loss(self, L, I):
        """照明层平滑损失"""
        # 计算梯度
        dx = torch.abs(L[:, :, :, :-1] - L[:, :, :, 1:])
        dy = torch.abs(L[:, :, :-1, :] - L[:, :, 1:, :])
        
        # 图像梯度指导平滑
        if I.size(1) == 3:
            I_gray = 0.299 * I[:, 0:1] + 0.587 * I[:, 1:2] + 0.114 * I[:, 2:3]
        else:
            I_gray = I
            
        dx_I = torch.abs(I_gray[:, :, :, :-1] - I_gray[:, :, :, 1:])
        dy_I = torch.abs(I_gray[:, :, :-1, :] - I_gray[:, :, 1:, :])
        
        # 计算权重
        # 增加小常数防止除零
        weights_x = torch.exp(-dx_I)
        weights_y = torch.exp(-dy_I)
        
        # 计算加权损失
        loss_x = dx * weights_x
        loss_y = dy * weights_y
        
        return loss_x.mean() + loss_y.mean()
    
    def reconstruction_loss(self, I, R, L):
        """重建损失：I应该等于R*L"""
        I_recon = R * L
        return F.mse_loss(I, I_recon)
    
    def forward(self, low_light, normal_light, R_low, L_low, R_normal, L_normal, stage_idx=None):
        """
        计算总损失
        
        Args:
            low_light: 低光输入图像
            normal_light: 正常光照图像
            R_low: 从低光图像中分解出的反射层
            L_low: 从低光图像中分解出的照明层 
            R_normal: 从正常光照图像中分解出的反射层
            L_normal: 从正常光照图像中分解出的照明层
            stage_idx: 阶段索引，可用于对不同阶段使用不同的权重
        """
        r_loss = self.reflectance_consistency_loss(R_low, R_normal)
        l_loss = self.illumination_smoothness_loss(L_low, low_light)
        rec_loss = self.reconstruction_loss(low_light, R_low, L_low) + \
                   self.reconstruction_loss(normal_light, R_normal, L_normal)
        
        # 可以基于阶段调整权重
        gamma_r = 1.0
        gamma_l = 1.0
        gamma_rec = 1.0
        
        total_loss = gamma_r * r_loss + gamma_l * l_loss + gamma_rec * rec_loss
        
        return total_loss, {
            'r_loss': r_loss.item(),
            'l_loss': l_loss.item(),
            'rec_loss': rec_loss.item()
        }

class AdjNetLoss(nn.Module):
    """AdjNet的损失函数"""
    def __init__(self):
        super(AdjNetLoss, self).__init__()
        self.mse_loss = nn.MSELoss()
        self.perceptual_loss = VGGPerceptualLoss()
        self.color_loss = ColorLoss()
        self.ssim_loss = StructuralLoss()
        
    def forward(self, enhanced, R_adj, L_adj, normal_light, R_normal, L_normal, low_light, lbs_output, lbs_target):
        """
        计算总损失
        
        Args:
            enhanced: 增强后的图像
            R_adj: 调整后的反射层
            L_adj: 调整后的照明层
            normal_light: 正常光照图像
            R_normal: 从正常光照图像中分解出的反射层
            L_normal: 从正常光照图像中分解出的照明层
            low_light: 低光输入图像
            lbs_output: LBS模块的输出
            lbs_target: LBS模块的目标
        """
        # 增强图像应接近正常光照图像
        l_enh = self.mse_loss(enhanced, normal_light)
        
        # 调整后的反射层应接近正常光照图像的反射层
        l_r_adj = self.ssim_loss(R_adj, R_normal)
        
        # 调整后的照明层应接近正常光照图像的照明层
        l_l_adj = self.mse_loss(L_adj, L_normal)
        
        # LBS损失
        l_lbs = self.mse_loss(lbs_output, lbs_target)
        
        # 感知损失
        l_percep = self.perceptual_loss(enhanced, normal_light)
        
        # 颜色损失
        l_color = self.color_loss(enhanced, normal_light)
        
        # 总损失
        total_loss = 0.05 * l_enh + 0.05 * l_r_adj + 0.1 * l_l_adj + 0.2 * l_lbs + 0.1 * l_percep + 20 * l_color
        
        return total_loss, {
            'l_enh': l_enh.item(),
            'l_r_adj': l_r_adj.item(),
            'l_l_adj': l_l_adj.item(),
            'l_lbs': l_lbs.item(),
            'l_percep': l_percep.item(),
            'l_color': l_color.item()
        }

class FineTuneLoss(nn.Module):
    """自监督微调的损失函数"""
    def __init__(self):
        super(FineTuneLoss, self).__init__()
        self.ssim_loss = StructuralLoss()
        
    def forward(self, enhanced, syn_normal):
        """
        计算总损失
        
        Args:
            enhanced: 增强后的图像
            syn_normal: 合成的正常光照图像
        """
        return self.ssim_loss(enhanced, syn_normal) 