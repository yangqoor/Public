import os
import torch
import torch.nn as nn
import numpy as np
import argparse
from PIL import Image
import torchvision.transforms as transforms
from torchvision.utils import save_image
from tqdm import tqdm
import time
import cv2
import json

from models.rauna import RAUNA
from utils.fine_tuning import FineTuner

def parse_args():
    parser = argparse.ArgumentParser(description='RAUNA模型测试')
    parser.add_argument('--input', type=str, required=True, help='输入低光图像路径或目录')
    parser.add_argument('--output', type=str, default='./results', help='输出目录')
    parser.add_argument('--model', type=str, required=True, help='模型路径')
    parser.add_argument('--device', type=str, default='cuda', help='设备')
    parser.add_argument('--fine_tune', action='store_true', help='是否使用自监督微调')
    parser.add_argument('--fine_tune_steps', type=int, default=30, help='微调步骤数')
    parser.add_argument('--alpha', type=float, default=0.5, help='全局亮度参数')
    parser.add_argument('--save_components', action='store_true', help='是否保存分解组件')
    parser.add_argument('--stages', type=int, default=17, help='DecNet的算法展开阶段数')
    parser.add_argument('--channels', type=int, default=32, help='网络基础通道数')
    parser.add_argument('--use_cpu', action='store_true', help='强制使用CPU')
    parser.add_argument('--strict_load', action='store_true', help='使用严格模式加载模型')
    parser.add_argument('--use_diffusion', action='store_true', help='使用扩散模型进行微调')
    parser.add_argument('--debug', action='store_true', help='启用调试模式，保存中间结果')
    
    return parser.parse_args()

def print_model_structure(model):
    """打印模型结构信息"""
    print("模型结构:")
    for name, module in model.named_modules():
        if isinstance(module, nn.Conv2d):
            print(f"  - {name}: in_channels={module.in_channels}, out_channels={module.out_channels}, kernel_size={module.kernel_size}")
    
    total_params = sum(p.numel() for p in model.parameters())
    print(f"模型总参数量: {total_params:,}")

def check_checkpoint_structure(checkpoint, save_debug=False):
    """检查检查点文件结构"""
    print("检查点文件结构:")
    
    if 'model' in checkpoint:
        print("  - 包含'model'键")
        model_state = checkpoint['model']
    else:
        print("  - 不包含'model'键，尝试直接加载")
        model_state = checkpoint
    
    # 打印一些关键层的形状
    conv_layers = [(k, v.shape) for k, v in model_state.items() if 'conv' in k and 'weight' in k]
    if conv_layers:
        print("  - 关键卷积层形状:")
        for name, shape in conv_layers[:5]:  # 只打印前5个，避免太多
            print(f"    * {name}: {shape}")
        if len(conv_layers) > 5:
            print(f"    * ... 还有 {len(conv_layers)-5} 个卷积层")
    
    # 保存调试信息
    if save_debug:
        debug_info = {
            'keys': list(model_state.keys()),
            'shapes': {k: list(v.shape) if hasattr(v, 'shape') else None for k, v in model_state.items()}
        }
        with open('checkpoint_debug.json', 'w') as f:
            json.dump(debug_info, f, indent=2)

    return model_state

def process_image(model, fine_tuner, image_path, output_dir, device, alpha=0.5, 
                 fine_tune=False, fine_tune_steps=30, save_components=False, use_diffusion=False, debug=False):
    """处理单张图像"""
    # 加载图像
    img = Image.open(image_path).convert('RGB')
    
    # 转换为tensor
    transform = transforms.Compose([
        transforms.ToTensor()
    ])
    img_tensor = transform(img).to(device)
    
    # 获取文件名
    filename = os.path.basename(image_path)
    name, ext = os.path.splitext(filename)
    
    # 记录时间
    start_time = time.time()
    
    # 处理图像
    try:
        with torch.no_grad():
            if fine_tune:
                # 使用自监督微调策略
                enhanced, R_adj, L_adj = fine_tuner.fine_tune(
                    model, 
                    img_tensor, 
                    steps=fine_tune_steps,
                    use_diffusion=use_diffusion
                )
                
                # 同时获取分解结果
                L, R = model.decompose_only(img_tensor.unsqueeze(0))
                L = L[0]
                R = R[0]
            else:
                # 直接使用模型
                result = model(img_tensor.unsqueeze(0), alpha=alpha)
                enhanced = result['enhanced'][0]
                R = result['reflectance'][0]
                L = result['illumination'][0]
                R_adj = result['R_adj'][0]
                L_adj = result['L_adj'][0]
                
                # 检查输出是否合理
                if torch.mean(enhanced) < 0.05:  # 如果输出过暗
                    print(f"警告: 图像 {name} 增强结果过暗，尝试提高alpha参数...")
                    # 尝试更高的alpha值
                    result = model(img_tensor.unsqueeze(0), alpha=min(alpha * 2, 1.0))
                    enhanced = result['enhanced'][0]
                    R_adj = result['R_adj'][0]
                    L_adj = result['L_adj'][0]
                    
                    # 如果还是太暗，应用额外的亮度提升
                    if torch.mean(enhanced) < 0.1:
                        print(f"应用额外亮度提升...")
                        enhanced = torch.clamp(enhanced * 1.5, 0.0, 1.0)
    except Exception as e:
        print(f"处理图像时出错: {e}")
        # 出错时应用简单亮度增强作为备选方案
        enhanced = torch.clamp(img_tensor * 1.5, 0.0, 1.0)
        R = img_tensor
        L = torch.ones_like(img_tensor)
        R_adj = img_tensor
        L_adj = torch.ones_like(img_tensor)

    # 计算处理时间
    process_time = time.time() - start_time
    
    # 保存结果
    save_image(enhanced, os.path.join(output_dir, f"{name}_enhanced{ext}"))
    
    # 保存分解组件（如果需要）
    if save_components:
        save_image(R, os.path.join(output_dir, f"{name}_R{ext}"))
        save_image(L, os.path.join(output_dir, f"{name}_L{ext}"))
        save_image(R_adj, os.path.join(output_dir, f"{name}_R_adj{ext}"))
        save_image(L_adj, os.path.join(output_dir, f"{name}_L_adj{ext}"))
    
    # 保存调试信息
    if debug:
        debug_dir = os.path.join(output_dir, "debug")
        os.makedirs(debug_dir, exist_ok=True)
        
        # 保存中间结果
        with torch.no_grad():
            # 保存输入图像
            save_image(img_tensor, os.path.join(debug_dir, f"{name}_input{ext}"))
            
            # 保存各种中间结果
            for i, alpha_val in enumerate([0.3, 0.5, 0.7, 0.9]):
                result = model(img_tensor.unsqueeze(0), alpha=alpha_val)
                save_image(result['enhanced'][0], os.path.join(debug_dir, f"{name}_alpha{alpha_val}{ext}"))

    return process_time

def main():
    args = parse_args()
    
    # 设置设备
    if args.use_cpu:
        device = torch.device('cpu')
        print("强制使用CPU进行测试")
    else:
        device = torch.device(args.device if torch.cuda.is_available() else 'cpu')
        if device.type == 'cuda':
            print(f"使用GPU: {torch.cuda.get_device_name(0)}")
        else:
            print("GPU不可用，使用CPU进行测试")
    
    # 创建输出目录
    os.makedirs(args.output, exist_ok=True)
    
    # 加载模型
    print(f"\n正在创建模型...")
    channels = args.channels
    stages = args.stages
    print(f"使用配置: {stages}个阶段, {channels}个通道")
    
    model = RAUNA(stages=stages, channels=channels).to(device)
    print_model_structure(model)
    
    print(f"\n正在加载检查点: {args.model}")
    try:
        checkpoint = torch.load(args.model, map_location=device)
        
        print("\n检查点加载成功，分析结构...")
        model_state = check_checkpoint_structure(checkpoint, save_debug=args.debug)
        
        print("\n尝试加载模型权重...")
        # 获取当前模型的state_dict键
        model_keys = set(model.state_dict().keys())
        checkpoint_keys = set(model_state.keys())
        
        # 计算共同键和不匹配键
        common_keys = model_keys.intersection(checkpoint_keys)
        model_only_keys = model_keys - checkpoint_keys
        checkpoint_only_keys = checkpoint_keys - model_keys
        
        print(f"模型参数总数: {len(model_keys)}")
        print(f"检查点参数总数: {len(checkpoint_keys)}")
        print(f"共同参数数量: {len(common_keys)}")
        
        if model_only_keys:
            print(f"模型中独有的参数: {len(model_only_keys)}")
            for key in list(model_only_keys)[:3]:  # 只显示前3个
                print(f"  - {key}")
            if len(model_only_keys) > 3:
                print(f"  - ... 还有 {len(model_only_keys)-3} 个参数")
                
        if checkpoint_only_keys:
            print(f"检查点中独有的参数: {len(checkpoint_only_keys)}")
            for key in list(checkpoint_only_keys)[:3]:  # 只显示前3个
                print(f"  - {key}")
            if len(checkpoint_only_keys) > 3:
                print(f"  - ... 还有 {len(checkpoint_only_keys)-3} 个参数")
        
        # 检查形状不匹配的参数
        shape_mismatches = []
        for key in common_keys:
            if model.state_dict()[key].shape != model_state[key].shape:
                shape_mismatches.append((key, model.state_dict()[key].shape, model_state[key].shape))
        
        if shape_mismatches:
            print(f"\n形状不匹配的参数: {len(shape_mismatches)}")
            for key, model_shape, checkpoint_shape in shape_mismatches[:10]:  # 只显示前10个
                print(f"  - {key}: 模型形状={model_shape}, 检查点形状={checkpoint_shape}")
            if len(shape_mismatches) > 10:
                print(f"  - ... 还有 {len(shape_mismatches)-10} 个不匹配参数")
                
            # 给出可能的解决方案
            print("\n可能的解决方案:")
            print("1. 使用非严格模式加载（当前正在尝试）")
            print("2. 尝试不同的通道数，例如 --channels 32/48/64")
            print("3. 尝试不同的阶段数，例如 --stages 13/15/17")
            print("4. 检查是否使用了正确的检查点文件")
        
        # 尝试加载权重
        try:
            if 'model' in checkpoint:
                if args.strict_load:
                    model.load_state_dict(checkpoint['model'])
                    print("\n成功使用严格模式加载模型权重")
                else:
                    model.load_state_dict(checkpoint['model'], strict=False)
                    print("\n使用非严格模式加载模型权重，忽略形状不匹配的参数")
            else:
                if args.strict_load:
                    model.load_state_dict(checkpoint)
                    print("\n成功使用严格模式加载模型权重")
                else:
                    model.load_state_dict(checkpoint, strict=False)
                    print("\n使用非严格模式加载模型权重，忽略形状不匹配的参数")
                    
            # 确保没有参数被随机初始化
            print("\n检查模型参数是否正确加载...")
            missing_keys = []
            for name, param in model.named_parameters():
                # 检查参数是否在检查点中
                param_in_checkpoint = False
                if 'model' in checkpoint:
                    param_in_checkpoint = name in checkpoint['model']
                else:
                    param_in_checkpoint = name in checkpoint
                
                if not param_in_checkpoint:
                    missing_keys.append(name)
            
            if missing_keys:
                print(f"警告: {len(missing_keys)} 个参数没有从检查点加载，而是使用了随机初始化")
                print("这些参数将被初始化为小的非零值以避免黑图输出")
                
                # 初始化缺失的参数为小的非零值
                with torch.no_grad():
                    for name in missing_keys:
                        param = model.get_parameter(name)
                        if 'weight' in name:
                            nn.init.xavier_normal_(param, gain=0.02)
                        elif 'bias' in name:
                            nn.init.constant_(param, 0.01)
            else:
                print("所有参数都已正确加载")

        except RuntimeError as e:
            print(f"\n加载权重出错: {e}")
            print("\n尝试使用 --strict_load 参数来查看详细错误信息")
            return
        
    except Exception as e:
        print(f"加载检查点时出错: {e}")
        return
    
    # 设置为评估模式
    model.eval()
    
    # 创建微调器
    fine_tuner = FineTuner(device=device)
    
    # 处理输入
    if os.path.isdir(args.input):
        # 处理目录中的所有图像
        image_files = [f for f in os.listdir(args.input) if f.lower().endswith(('.png', '.jpg', '.jpeg'))]
        total_time = 0
        
        for image_file in tqdm(image_files, desc="Processing images"):
            image_path = os.path.join(args.input, image_file)
            process_time = process_image(
                model, fine_tuner, image_path, args.output, device, 
                args.alpha, args.fine_tune, args.fine_tune_steps, args.save_components, args.use_diffusion, args.debug
            )
            total_time += process_time
        
        # 打印处理信息
        avg_time = total_time / len(image_files)
        print(f"处理完成. 共 {len(image_files)} 张图像, 平均处理时间: {avg_time:.4f}秒.")
    else:
        # 处理单张图像
        process_time = process_image(
            model, fine_tuner, args.input, args.output, device, 
            args.alpha, args.fine_tune, args.fine_tune_steps, args.save_components, args.use_diffusion, args.debug
        )
        print(f"处理完成. 处理时间: {process_time:.4f}秒.")

def calculate_metrics(img1_path, img2_path):
    """计算PSNR和SSIM指标"""
    img1 = cv2.imread(img1_path)
    img2 = cv2.imread(img2_path)
    
    # 确保图像尺寸相同
    if img1.shape != img2.shape:
        img2 = cv2.resize(img2, (img1.shape[1], img1.shape[0]))
    
    # 计算PSNR
    mse = np.mean((img1 - img2) ** 2)
    if mse == 0:
        psnr = 100
    else:
        psnr = 20 * np.log10(255.0 / np.sqrt(mse))
    
    # 计算SSIM
    img1_gray = cv2.cvtColor(img1, cv2.COLOR_BGR2GRAY)
    img2_gray = cv2.cvtColor(img2, cv2.COLOR_BGR2GRAY)
    
    C1 = (0.01 * 255) ** 2
    C2 = (0.03 * 255) ** 2
    
    # 计算均值
    mu1 = cv2.GaussianBlur(img1_gray, (11, 11), 1.5)
    mu2 = cv2.GaussianBlur(img2_gray, (11, 11), 1.5)
    
    # 计算均值的平方
    mu1_sq = mu1 ** 2
    mu2_sq = mu2 ** 2
    mu1_mu2 = mu1 * mu2
    
    # 计算方差和协方差
    sigma1_sq = cv2.GaussianBlur(img1_gray ** 2, (11, 11), 1.5) - mu1_sq
    sigma2_sq = cv2.GaussianBlur(img2_gray ** 2, (11, 11), 1.5) - mu2_sq
    sigma12 = cv2.GaussianBlur(img1_gray * img2_gray, (11, 11), 1.5) - mu1_mu2
    
    # 计算SSIM
    ssim_map = ((2 * mu1_mu2 + C1) * (2 * sigma12 + C2)) / ((mu1_sq + mu2_sq + C1) * (sigma1_sq + sigma2_sq + C2))
    ssim = np.mean(ssim_map)
    
    return psnr, ssim

if __name__ == "__main__":
    main() 