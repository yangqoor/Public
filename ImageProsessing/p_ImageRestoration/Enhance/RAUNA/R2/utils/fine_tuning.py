import torch
import torch.nn as nn
import torch.nn.functional as F
import cv2
import numpy as np
import os

# 添加扩散模型相关导入
try:
    from diffusers import StableDiffusionImg2ImgPipeline, DDPMScheduler
    from diffusers.utils import load_image
    import torch.nn.functional as F
    DIFFUSION_AVAILABLE = True
except ImportError:
    DIFFUSION_AVAILABLE = False
    print("警告: 扩散模型相关库未安装，将使用传统方法。")

class DiffusionPrior:
    """扩散模型先验生成器，用于提供高质量图像先验信息"""
    def __init__(self, model_id="stabilityai/stable-diffusion-2-1", device='cuda'):
        global DIFFUSION_AVAILABLE
        self.device = device
        self.model_id = model_id
        self.pipe = None
        
        # 只在可用时初始化
        if DIFFUSION_AVAILABLE:
            try:
                self.pipe = StableDiffusionImg2ImgPipeline.from_pretrained(
                    model_id, 
                    torch_dtype=torch.float16 if torch.cuda.is_available() else torch.float32
                ).to(device)
                print(f"扩散模型初始化成功: {model_id}")
            except Exception as e:
                DIFFUSION_AVAILABLE = False
                print(f"扩散模型初始化失败: {e}")
    
    def is_available(self):
        """检查扩散模型是否可用"""
        return DIFFUSION_AVAILABLE and self.pipe is not None
    
    def generate_image(self, img_tensor, prompt="a well-lit, clear photograph with good lighting", 
                       strength=0.75, guidance_scale=7.5):
        """
        从低光图像生成高质量正常光照图像
        
        Args:
            img_tensor: 输入的低光图像Tensor
            prompt: 文本提示，引导生成的图像特性
            strength: 保留原始图像内容的程度 (0-1)
            guidance_scale: 文本引导强度
            
        Returns:
            生成的正常光照图像Tensor
        """
        if not self.is_available():
            # 返回空值，表示需要使用备用方法
            return None
            
        # 转换为PIL图像
        if img_tensor.dim() == 4:
            img_tensor = img_tensor[0]  # 取批次中第一张
            
        img_np = img_tensor.detach().cpu().permute(1, 2, 0).numpy()
        img_np = np.clip(img_np * 255, 0, 255).astype(np.uint8)
        
        # 创建PIL图像
        from PIL import Image
        pil_image = Image.fromarray(img_np)
        
        try:
            # 使用扩散模型生成增强图像
            with torch.no_grad():
                output = self.pipe(
                    prompt=prompt,
                    image=pil_image,
                    strength=strength,
                    guidance_scale=guidance_scale,
                    num_inference_steps=50
                )
            
            # 转换为tensor
            gen_image = np.array(output.images[0])
            gen_tensor = torch.from_numpy(gen_image).float() / 255.0
            gen_tensor = gen_tensor.permute(2, 0, 1)
            
            if torch.cuda.is_available() and self.device == 'cuda':
                gen_tensor = gen_tensor.cuda()
                
            return gen_tensor
        except Exception as e:
            print(f"扩散模型生成失败: {e}")
            return None
    
    def extract_structure_prior(self, img_tensor, steps=10):
        """
        从图像中提取隐式结构先验
        
        Args:
            img_tensor: 输入图像Tensor
            steps: 扩散模型推理步骤数
            
        Returns:
            结构先验Tensor
        """
        if not self.is_available():
            return None
            
        # 提取DDPM中间结果作为结构先验
        try:
            if img_tensor.dim() == 4:
                batch_size = img_tensor.size(0)
                results = []
                for i in range(batch_size):
                    prior = self.extract_structure_prior(img_tensor[i])
                    results.append(prior)
                return torch.stack(results)
            
            # 转换为适合DDPM处理的格式
            noise_pred = None
            
            # 根据输入特性调整先验提取方法
            if img_tensor.dim() == 3:
                # 单个图像
                # 使用DDPM噪声预测器提取结构信息
                scheduler = DDPMScheduler()
                noisy_image = scheduler.add_noise(img_tensor.unsqueeze(0), 
                                                 torch.randn_like(img_tensor.unsqueeze(0)), 
                                                 torch.tensor([5]))
                                                 
                # 这里简化处理，实际应使用模型的UNet提取器
                denoised = self.pipe.unet(noisy_image)
                noise_pred = denoised.sample
                
                # 提取结构特征
                structure_prior = noise_pred - noisy_image
                
                return structure_prior[0]
            
        except Exception as e:
            print(f"结构先验提取失败: {e}")
            return None

class FineTuner:
    """自监督微调工具"""
    def __init__(self, device='cuda'):
        self.device = device
        
        # 初始化扩散模型先验生成器
        self.diffusion = DiffusionPrior(device=device)
        
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
        clahe = cv2.createCLAHE(clipLimit=3.0, tileGridSize=(8,8))  # 增加clipLimit提高亮度
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
        """
        合成正常光照图像作为微调的指导
        优先使用扩散模型，失败时回退到传统方法
        """
        # 尝试使用扩散模型生成高质量参考图像
        if self.diffusion.is_available():
            print("使用扩散模型生成高质量伪正常光照参考图像...")
            diffusion_enhanced = self.diffusion.generate_image(
                low_light_img,
                prompt="a clear photograph with perfect lighting, high quality, detailed",
                strength=0.8
            )
            
            if diffusion_enhanced is not None:
                print("扩散模型生成成功！")
                return diffusion_enhanced
            
        # 扩散模型不可用或失败，回退到传统方法
        print("扩散模型不可用，使用传统方法(CLAHE+BM3D)合成参考图像")
        
        # 先用CLAHE增强亮度和对比度
        enhanced = self.clahe_enhance(low_light_img)
        
        # 尝试用BM3D去噪
        try:
            denoised = self.bm3d_denoise(enhanced)
        except:
            denoised = enhanced
            
        # 提高整体亮度
        brightened = torch.clamp(denoised * 1.5, 0.0, 1.0)
        
        return brightened
    
    def gamma_correction(self, img, gamma=0.6):
        """应用gamma校正来增加亮度"""
        return torch.pow(img, gamma)
    
    def apply_diffusion_prior(self, model, img_tensor, L, R):
        """
        应用扩散模型的隐式先验来改进分解结果
        
        Args:
            model: RAUNA模型
            img_tensor: 输入图像
            L: 照明层
            R: 反射层
            
        Returns:
            改进后的照明层和反射层
        """
        if not self.diffusion.is_available():
            # 扩散模型不可用，返回原始分解
            return L, R
            
        # 提取扩散模型的结构先验
        structure_prior = self.diffusion.extract_structure_prior(R)
        
        if structure_prior is None:
            # 先验提取失败，返回原始分解
            return L, R
            
        # 将先验应用到分解结果上
        # 这里使用一个加权合并策略
        with torch.no_grad():
            # 通过模型的结构先验模块处理
            G = model.decnet.stages[-1].structure_prior(R.unsqueeze(0) if R.dim() == 3 else R)
            
            # 融合扩散模型的先验与模型内置先验
            if structure_prior.dim() == 3:
                structure_prior = structure_prior.unsqueeze(0)
                
            # 调整先验形状以匹配
            if structure_prior.shape != G.shape:
                structure_prior = F.interpolate(
                    structure_prior, 
                    size=G.shape[2:], 
                    mode='bilinear', 
                    align_corners=False
                )
            
            # 融合两种先验，偏向于扩散模型的先验（假设其质量更高）
            combined_prior = 0.7 * structure_prior + 0.3 * G
            
            # 应用到反射层
            R_improved = R + 0.1 * combined_prior[0] if combined_prior.dim() == 4 else combined_prior
            
            # 照明层可以保持不变，或通过照明一致性约束调整
            L_improved = L
            
        return L_improved, R_improved
        
    def fine_tune(self, model, low_light_img, steps=30, lr=1e-4, use_diffusion=False):
        """
        对单张图像进行自监督微调 - 使用扩散模型增强版本

        Args:
            model: RAUNA模型
            low_light_img: 低光输入图像
            steps: 微调步骤数
            lr: 学习率
            use_diffusion: 是否使用扩散模型 (新增参数)

        Returns:
            增强后的图像
        """
        # 确保输入图像在设备上
        device = next(model.parameters()).device
        if low_light_img.device != device:
            low_light_img = low_light_img.to(device)

        # 使用扩散模型生成高质量的伪正常光照图像
        syn_normal = self.synthesize_normal_image(low_light_img)

        # 分解阶段 - 获取初始分解
        with torch.no_grad():
            L, R = model.decompose_only(low_light_img.unsqueeze(0))
            L = L[0] if L.dim() == 4 else L
            R = R[0] if R.dim() == 4 else R

            # 如果使用扩散模型且可用，应用扩散模型的隐式先验改进分解
            if use_diffusion and self.diffusion.is_available():
                L_improved, R_improved = self.apply_diffusion_prior(model, low_light_img, L, R)
            else:
                L_improved, R_improved = L, R

        # 检查扩散模型是否可用，决定使用哪种微调方法
        if use_diffusion and self.diffusion.is_available():
            try:
                print("尝试基于扩散模型的自监督微调...")
                L_opt = L_improved.clone().detach().requires_grad_(True)
                R_opt = R_improved.clone().detach().requires_grad_(True)
                alpha_opt = torch.tensor(0.8, dtype=torch.float32, requires_grad=True, device=device)  

                # 创建优化器 - 使用Adam优化器
                optimizer = torch.optim.Adam([L_opt, R_opt, alpha_opt], lr=lr)

                # 使用更高质量的合成正常光照图像作为目标
                target = syn_normal.to(device)
                target_batch = target.unsqueeze(0)

                # MSE损失
                criterion = nn.MSELoss()

                # 添加结构相似性损失和感知损失（如果可能）
                try:
                    from utils.losses import StructuralLoss
                    ssim_loss = StructuralLoss().to(device)
                    use_ssim = True
                except Exception:
                    use_ssim = False
                    print("结构相似性损失不可用，使用基本MSE损失")

                # 微调循环 - 使用扩散模型的结构先验作为正则化
                for step in range(steps):
                    # 计算增强图像
                    enhanced = R_opt * L_opt

                    # 基础MSE损失
                    loss = criterion(enhanced.unsqueeze(0), target_batch)

                    # 添加结构相似性损失（如果可用）
                    if use_ssim:
                        structure_loss = ssim_loss(enhanced.unsqueeze(0), target_batch)
                        loss = loss + 0.5 * structure_loss

                    # 反向传播
                    optimizer.zero_grad()
                    loss.backward()
                    optimizer.step()

                    # 投影确保参数在合理范围内
                    with torch.no_grad():
                        L_opt.data.clamp_(0.01, 1.0)
                        R_opt.data.clamp_(0.01, 1.0)
                        alpha_opt.data.clamp_(0.1, 1.0)

                # 使用优化后的参数进行最终增强
                with torch.no_grad():
                    enhanced, R_adj, L_adj = model.enhance_with_decomposition(
                        (L_opt.unsqueeze(0), R_opt.unsqueeze(0)), alpha_opt.item())

                    # 确保输出亮度合理
                    if torch.mean(enhanced) < 0.1:
                        print("微调后输出亮度仍然较低，应用额外亮度提升")
                        enhanced = torch.clamp(enhanced * 1.5, 0.0, 1.0)

                return enhanced[0], R_adj[0], L_adj[0]

            except Exception as e:
                print(f"基于扩散模型的微调失败，回退到直接处理: {e}")
                # 继续使用备选方法

        # 备选方法：直接使用模型处理图像 + 后处理增强
        print("使用直接处理 + 后处理增强方法..")
        with torch.no_grad():
            # 使用原始模型进行处理
            results = model(low_light_img.unsqueeze(0), alpha=0.8)  # 增加alpha参数提高亮度     
            enhanced = results['enhanced'][0]
            R_adj = results['R_adj'][0]
            L_adj = results['L_adj'][0]

            # 对增强后的图像应用CLAHE来进一步提高质量
            enhanced_clahe = self.clahe_enhance(enhanced)

            # 应用gamma校正提高亮度
            gamma_enhanced = self.gamma_correction(enhanced)

            # 混合多种结果取最佳效果
            # 将原始低光图像作为参考，确保结果不会比输入更暗
            low_light_brightness = torch.mean(low_light_img)
            enhanced_brightness = torch.mean(enhanced)

            if enhanced_brightness < low_light_brightness:
                print("警告: 增强后的图像比原始低光图像更暗，应用补偿")
                brightness_ratio = low_light_brightness / (enhanced_brightness + 1e-6)
                enhanced = torch.clamp(enhanced * brightness_ratio * 1.2, 0.0, 1.0)

            # 混合结果
            final_enhanced = 0.4 * enhanced_clahe + 0.3 * gamma_enhanced + 0.3 * enhanced

            # 确保最终结果亮度充足
            final_brightness = torch.mean(final_enhanced)
            if final_brightness < 0.4:  # 如果整体亮度仍然不足
                brightness_boost = max(1.0, 0.4 / (final_brightness + 1e-6))
                final_enhanced = torch.clamp(final_enhanced * brightness_boost, 0.0, 1.0)

        # 返回所有结果
        return final_enhanced, R_adj, L_adj
        
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
                loss.backward()
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
        
        return enhanced[0], R_adj[0], L_adj[0] 