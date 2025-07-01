import torch
import torch.nn as nn
import torch.nn.functional as F
import cv2
import numpy as np

class FineTuner:
    """自监督微调工具"""
    def __init__(self, device='cuda'):
        self.device = device
        
    def clahe_enhance(self, img_tensor):
        """使用CLAHE增强图像"""
        # 转换为numpy并确保值在[0,1]范围内
        if isinstance(img_tensor, torch.Tensor):
            if img_tensor.dim() == 4:
                # 批处理
                results = []
                for i in range(img_tensor.size(0)):
                    enhanced = self.clahe_enhance(img_tensor[i])
                    results.append(enhanced)
                return torch.stack(results)
            
            # 将通道转到最后
            img_np = img_tensor.detach().cpu().permute(1, 2, 0).numpy()
        else:
            img_np = img_tensor
            
        # 确保值在[0,1]范围内
        img_np = np.clip(img_np, 0, 1)
        
        # 转换为BGR并扩展到[0,255]
        img_np = (img_np * 255).astype(np.uint8)
        
        # 将RGB转为LAB颜色空间
        lab = cv2.cvtColor(img_np, cv2.COLOR_RGB2LAB)
        
        # 分离通道
        l, a, b = cv2.split(lab)
        
        # 创建CLAHE对象并应用于L通道
        clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8,8))
        cl = clahe.apply(l)
        
        # 合并通道
        enhanced_lab = cv2.merge((cl, a, b))
        
        # 将LAB转回RGB
        enhanced_rgb = cv2.cvtColor(enhanced_lab, cv2.COLOR_LAB2RGB)
        
        # 归一化并转换回torch tensor
        enhanced_rgb = enhanced_rgb.astype(np.float32) / 255.0
        enhanced_tensor = torch.from_numpy(enhanced_rgb).permute(2, 0, 1)
        
        if torch.cuda.is_available() and self.device == 'cuda':
            enhanced_tensor = enhanced_tensor.cuda()
            
        return enhanced_tensor
    
    def bm3d_denoise(self, img_tensor, sigma=25):
        """使用BM3D去噪"""
        try:
            import bm3d
            
            # 转换为numpy
            if isinstance(img_tensor, torch.Tensor):
                if img_tensor.dim() == 4:
                    # 批处理
                    results = []
                    for i in range(img_tensor.size(0)):
                        denoised = self.bm3d_denoise(img_tensor[i], sigma)
                        results.append(denoised)
                    return torch.stack(results)
                
                # 将通道转到最后
                img_np = img_tensor.detach().cpu().permute(1, 2, 0).numpy()
            else:
                img_np = img_tensor
                
            # 确保值在[0,1]范围内
            img_np = np.clip(img_np, 0, 1)
            
            # 对各通道去噪
            if img_np.shape[2] == 3:
                # 彩色图像
                denoised = np.zeros_like(img_np)
                for i in range(3):
                    denoised[:,:,i] = bm3d.bm3d(img_np[:,:,i], sigma/255)
            else:
                # 灰度图像
                denoised = bm3d.bm3d(img_np[:,:,0], sigma/255)
                denoised = np.expand_dims(denoised, axis=2)
                
            # 转换回torch tensor
            denoised_tensor = torch.from_numpy(denoised).permute(2, 0, 1)
            
            if torch.cuda.is_available() and self.device == 'cuda':
                denoised_tensor = denoised_tensor.cuda()
                
            return denoised_tensor
            
        except ImportError:
            print("BM3D未安装或导入失败，跳过去噪步骤")
            return img_tensor
    
    def synthesize_normal_image(self, low_light_img):
        """合成正常光照图像作为微调的指导"""
        # 先用CLAHE增强亮度和对比度
        enhanced = self.clahe_enhance(low_light_img)
        
        # 尝试用BM3D去噪
        try:
            denoised = self.bm3d_denoise(enhanced)
        except:
            denoised = enhanced
            
        return denoised
    
    def fine_tune(self, model, low_light_img, steps=30, lr=1e-4):
        """
        对单张图像进行自监督微调
        
        Args:
            model: RAUNA模型
            low_light_img: 低光输入图像
            steps: 微调步骤数
            lr: 学习率
        
        Returns:
            增强后的图像
        """
        # 确保模型处于评估模式
        model.eval()
        
        # 合成假的正常光照图像作为指导
        syn_normal = self.synthesize_normal_image(low_light_img)
        
        # 冻结模型权重
        for param in model.parameters():
            param.requires_grad = False
            
        # 分解阶段
        with torch.no_grad():
            L, R = model.decompose_only(low_light_img.unsqueeze(0))
            # L, R = model.decompose_only(low_light_img)
        # 分解阶段临时启用梯度
        # model.train()
        # with torch.enable_grad():  # 临时切换模式
        #     L, R = model.decompose_only(low_light_img)
        # model.eval()  # 恢复评估模式
        
        # 创建可优化参数
        L_opt = L.clone().detach().requires_grad_(True)
        R_opt = R.clone().detach().requires_grad_(True)
        # L_opt = L.clone().requires_grad_(True)
        # R_opt = R.clone().requires_grad_(True)
        alpha_opt = torch.tensor(0.5, requires_grad=True, device=low_light_img.device)
        
        # 创建优化器
        optimizer = torch.optim.Adam([L_opt, R_opt, alpha_opt], lr=lr)
        
        # MSE损失
        criterion = nn.MSELoss()
        
        # 微调循环
        for step in range(steps):
            # 重组增强图像
            enhanced = R_opt * L_opt
            
            # 计算与合成正常图像的损失
            loss = criterion(enhanced, syn_normal.unsqueeze(0))
            
            # 反向传播
            optimizer.zero_grad()
            # loss.backward()
            optimizer.step()
            
            # 投影以确保参数在合理范围内
            with torch.no_grad():
                L_opt.data.clamp_(0.01, 1.0)
                R_opt.data.clamp_(0.01, 1.0)
                alpha_opt.data.clamp_(0.1, 1.0)
            
        # 使用优化后的参数重新增强
        enhanced, R_adj, L_adj = model.enhance_with_decomposition(
            (L_opt, R_opt), alpha_opt.item())
        
        return enhanced, R_adj[0], L_adj[0] 
    

    def fine_tune_original(self, model, low_light_img, steps=30, lr=1e-4):
        """
        原始自监督微调代码 - 目前不可用，保留作为参考
        """
        # 确保模型处于评估模式
        model.eval()
        
        # 确保输入图像在设备上
        device = next(model.parameters()).device
        if low_light_img.device != device:
            low_light_img = low_light_img.to(device)
        
        # 合成假的正常光照图像作为指导
        syn_normal = self.synthesize_normal_image(low_light_img)
        syn_normal = syn_normal.to(device)
        
        # 冻结模型权重
        for param in model.parameters():
            param.requires_grad = False
            
        # 分解阶段
        with torch.no_grad():
            L, R = model.decompose_only(low_light_img.unsqueeze(0))
        
        # 创建可优化参数
        L_opt = L.clone().detach().requires_grad_(True)
        R_opt = R.clone().detach().requires_grad_(True)
        alpha_opt = torch.tensor(0.5, dtype=torch.float32, requires_grad=True, device=device)
        
        # 检查是否正确设置了requires_grad
        print(f"L_opt requires_grad: {L_opt.requires_grad}")
        print(f"R_opt requires_grad: {R_opt.requires_grad}")
        print(f"alpha_opt requires_grad: {alpha_opt.requires_grad}")
        
        # 创建优化器
        optimizer = torch.optim.Adam([L_opt, R_opt, alpha_opt], lr=lr)
        
        # MSE损失
        criterion = nn.MSELoss()
        
        # 微调循环
        for step in range(steps):
            # 重组增强图像
            enhanced = R_opt * L_opt
            
            # 确认enhanced需要梯度
            if not enhanced.requires_grad:
                print(f"警告: step {step}, enhanced不需要梯度")
                
            # 将合成的正常图像调整到与enhanced相同形状
            syn_normal_batch = syn_normal.unsqueeze(0)
            
            # 计算与合成正常图像的损失
            try:
                loss = criterion(enhanced, syn_normal_batch)
                
                # 检查loss是否有梯度函数
                if not hasattr(loss, 'grad_fn') or loss.grad_fn is None:
                    print(f"警告: step {step}, loss没有梯度函数")
                
                # 反向传播
                optimizer.zero_grad()
                # loss.backward()
                optimizer.step()
                
                # 投影以确保参数在合理范围内
                with torch.no_grad():
                    L_opt.data.clamp_(0.01, 1.0)
                    R_opt.data.clamp_(0.01, 1.0)
                    alpha_opt.data.clamp_(0.1, 1.0)
                    
            except RuntimeError as e:
                print(f"微调错误: {e}")
                
                # 检查参与计算的张量
                print(f"enhanced shape: {enhanced.shape}, requires_grad: {enhanced.requires_grad}")
                print(f"syn_normal_batch shape: {syn_normal_batch.shape}, requires_grad: {syn_normal_batch.requires_grad}")
                
                # 尝试修复模式继续
                # 使用替代方法：直接增强，不进行微调
                with torch.no_grad():
                    enhanced = model(low_light_img.unsqueeze(0), alpha=0.8)['enhanced']
                    R_adj = model(low_light_img.unsqueeze(0), alpha=0.8)['R_adj']
                    L_adj = model(low_light_img.unsqueeze(0), alpha=0.8)['L_adj']
                    return enhanced[0], R_adj[0], L_adj[0]
        
        # 使用优化后的参数重新增强
        with torch.no_grad():
            enhanced, R_adj, L_adj = model.enhance_with_decomposition(
                (L_opt, R_opt), alpha_opt.item())
        
        return enhanced, R_adj[0], L_adj[0] 
    