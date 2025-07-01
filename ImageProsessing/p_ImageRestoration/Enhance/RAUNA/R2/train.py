import os
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader
import numpy as np
import argparse
from tqdm import tqdm
import cv2
from torchvision.utils import save_image
import gc  # 垃圾回收

from models.rauna import RAUNA
from utils.losses import DecNetLoss, AdjNetLoss
from datasets.lol_dataset import LOLDataset, PairedDataset

def parse_args():
    parser = argparse.ArgumentParser(description='RAUNA模型训练')
    parser.add_argument('--data_dir', type=str, default='./data/LOL', help='数据集根目录')
    parser.add_argument('--batch_size', type=int, default=4, help='批次大小')
    parser.add_argument('--epochs', type=int, default=100, help='训练轮数')
    parser.add_argument('--lr_dec', type=float, default=1e-4, help='DecNet的学习率')
    parser.add_argument('--lr_adj', type=float, default=1e-3, help='AdjNet的学习率')
    parser.add_argument('--crop_size', type=int, default=128, help='裁剪大小')
    parser.add_argument('--save_dir', type=str, default='./checkpoints', help='模型保存目录')
    parser.add_argument('--log_interval', type=int, default=10, help='日志间隔')
    parser.add_argument('--save_interval', type=int, default=5, help='保存间隔')
    parser.add_argument('--device', type=str, default='cuda', help='训练设备')
    parser.add_argument('--stages', type=int, default=13, help='DecNet的算法展开阶段数')
    parser.add_argument('--resume', type=str, default=None, help='恢复训练')
    parser.add_argument('--use_cpu', action='store_true', help='强制使用CPU训练')
    parser.add_argument('--channels', type=int, default=32, help='网络基础通道数')
    parser.add_argument('--use_mixed_precision', action='store_true', help='使用混合精度训练')
    parser.add_argument('--accumulation_steps', type=int, default=1, help='梯度累积步数')
    
    return parser.parse_args()

def clear_gpu_memory():
    """清理GPU内存"""
    torch.cuda.empty_cache()
    gc.collect()

def train_decomposition(model, dataloader, optimizer, criterion, device, epoch, total_epochs, 
                       log_interval=10, accumulation_steps=1, use_mixed_precision=False):
    """训练分解网络"""
    model.train()
    total_loss = 0
    
    progress_bar = tqdm(dataloader, desc=f"[Dec] Epoch {epoch}/{total_epochs}")
    
    # 混合精度训练
    scaler = torch.cuda.amp.GradScaler() if use_mixed_precision else None
    optimizer.zero_grad()
    
    for batch_idx, batch in enumerate(progress_bar):
        # 常规梯度清零改为更有效率的每accumulation_steps步清零一次
        if batch_idx % accumulation_steps == 0:
            optimizer.zero_grad()
        
        low = batch['low'].to(device)
        normal = batch['normal'].to(device)
        
        # 使用混合精度
        if use_mixed_precision:
            with torch.cuda.amp.autocast():
                # 分解低光和正常光照图像
                L_low, R_low = model.decompose_only(low)
                L_normal, R_normal = model.decompose_only(normal)
                
                # 计算损失
                loss, loss_dict = criterion(low, normal, R_low, L_low, R_normal, L_normal)
                loss = loss / accumulation_steps  # 梯度累积
                
            # 反向传播
            scaler.scale(loss).backward()
            
            # 每accumulation_steps步更新一次参数
            if (batch_idx + 1) % accumulation_steps == 0 or (batch_idx + 1) == len(dataloader):
                scaler.step(optimizer)
                scaler.update()
        else:
            # 分解低光和正常光照图像
            L_low, R_low = model.decompose_only(low)
            L_normal, R_normal = model.decompose_only(normal)
            
            # 计算损失
            loss, loss_dict = criterion(low, normal, R_low, L_low, R_normal, L_normal)
            loss = loss / accumulation_steps  # 梯度累积
            
            # 反向传播
            loss.backward()
            
            # 每accumulation_steps步更新一次参数
            if (batch_idx + 1) % accumulation_steps == 0 or (batch_idx + 1) == len(dataloader):
                optimizer.step()
                optimizer.zero_grad()
        
        # 更新总损失
        total_loss += loss.item() * accumulation_steps
        
        # 更新进度条
        if batch_idx % log_interval == 0:
            avg_loss = total_loss / (batch_idx + 1)
            progress_bar.set_postfix({
                'loss': f"{avg_loss:.4f}",
                'r_loss': f"{loss_dict['r_loss']:.4f}",
                'l_loss': f"{loss_dict['l_loss']:.4f}",
                'rec_loss': f"{loss_dict['rec_loss']:.4f}"
            })
        
        # 显式释放不需要的变量
        del low, normal, L_low, R_low, L_normal, R_normal, loss
        if batch_idx % 5 == 0:
            clear_gpu_memory()
    
    # 返回平均损失
    return total_loss / len(dataloader)

def train_adjustment(model, dataloader, optimizer, criterion, device, epoch, total_epochs, 
                    log_interval=10, accumulation_steps=1, use_mixed_precision=False):
    """训练调整网络"""
    model.train()
    total_loss = 0
    
    progress_bar = tqdm(dataloader, desc=f"[Adj] Epoch {epoch}/{total_epochs}")
    
    # 混合精度训练
    scaler = torch.cuda.amp.GradScaler() if use_mixed_precision else None
    optimizer.zero_grad()
    
    for batch_idx, batch in enumerate(progress_bar):
        # 常规梯度清零改为更有效率的每accumulation_steps步清零一次
        if batch_idx % accumulation_steps == 0:
            optimizer.zero_grad()
            
        low = batch['low'].to(device)
        normal = batch['normal'].to(device)
        
        # 使用混合精度
        if use_mixed_precision:
            with torch.cuda.amp.autocast():
                # 固定分解网络，只训练调整网络
                with torch.no_grad():
                    L_low, R_low = model.decompose_only(low)
                    L_normal, R_normal = model.decompose_only(normal)
                
                # 计算LBS目标
                if low.size(1) == 3:
                    low_gray = 0.299 * low[:, 0:1] + 0.587 * low[:, 1:2] + 0.114 * low[:, 2:3]
                    normal_gray = 0.299 * normal[:, 0:1] + 0.587 * normal[:, 1:2] + 0.114 * normal[:, 2:3]
                else:
                    low_gray = low
                    normal_gray = normal
                    
                lbs_target = (normal_gray - low_gray) * low_gray
                
                # 前向传播调整网络
                enhanced, R_adj, L_adj = model.adjnet(low, R_low, L_low)
                
                # LBS输出
                lbs_output = model.adjnet.lbs(low, L_low)
                
                # 计算损失
                loss, loss_dict = criterion(enhanced, R_adj, L_adj, normal, R_normal, L_normal, low, lbs_output, lbs_target)
                loss = loss / accumulation_steps  # 梯度累积
                
            # 反向传播
            scaler.scale(loss).backward()
            
            # 每accumulation_steps步更新一次参数
            if (batch_idx + 1) % accumulation_steps == 0 or (batch_idx + 1) == len(dataloader):
                scaler.step(optimizer)
                scaler.update()
        else:
            # 固定分解网络，只训练调整网络
            with torch.no_grad():
                L_low, R_low = model.decompose_only(low)
                L_normal, R_normal = model.decompose_only(normal)
            
            # 计算LBS目标
            if low.size(1) == 3:
                low_gray = 0.299 * low[:, 0:1] + 0.587 * low[:, 1:2] + 0.114 * low[:, 2:3]
                normal_gray = 0.299 * normal[:, 0:1] + 0.587 * normal[:, 1:2] + 0.114 * normal[:, 2:3]
            else:
                low_gray = low
                normal_gray = normal
                
            lbs_target = (normal_gray - low_gray) * low_gray
            
            # 前向传播调整网络
            enhanced, R_adj, L_adj = model.adjnet(low, R_low, L_low)
            
            # LBS输出
            lbs_output = model.adjnet.lbs(low, L_low)
            
            # 计算损失
            loss, loss_dict = criterion(enhanced, R_adj, L_adj, normal, R_normal, L_normal, low, lbs_output, lbs_target)
            loss = loss / accumulation_steps  # 梯度累积
            
            # 反向传播
            loss.backward()
            
            # 每accumulation_steps步更新一次参数
            if (batch_idx + 1) % accumulation_steps == 0 or (batch_idx + 1) == len(dataloader):
                optimizer.step()
                optimizer.zero_grad()
        
        # 更新总损失
        total_loss += loss.item() * accumulation_steps
        
        # 更新进度条
        if batch_idx % log_interval == 0:
            avg_loss = total_loss / (batch_idx + 1)
            progress_bar.set_postfix({
                'loss': f"{avg_loss:.4f}",
                'enh': f"{loss_dict['l_enh']:.4f}",
                'r_adj': f"{loss_dict['l_r_adj']:.4f}",
                'l_adj': f"{loss_dict['l_l_adj']:.4f}",
                'lbs': f"{loss_dict['l_lbs']:.4f}"
            })
        
        # 显式释放不需要的变量
        del low, normal, L_low, R_low, L_normal, R_normal, enhanced, R_adj, L_adj, lbs_output, lbs_target, loss
        if batch_idx % 5 == 0:
            clear_gpu_memory()
    
    # 返回平均损失
    return total_loss / len(dataloader)

def main():
    # 解析参数
    args = parse_args()
    
    # 设置设备
    if args.use_cpu:
        device = torch.device('cpu')
        print("强制使用CPU训练")
    else:
        device = torch.device(args.device if torch.cuda.is_available() else 'cpu')
        if device.type == 'cuda':
            print(f"使用GPU: {torch.cuda.get_device_name(0)}")
            print(f"GPU显存: {torch.cuda.get_device_properties(0).total_memory / 1024 / 1024 / 1024:.2f} GB")
        else:
            print("GPU不可用，使用CPU训练")
    
    # 创建保存目录
    os.makedirs(args.save_dir, exist_ok=True)
    
    # 加载数据集
    dataset = LOLDataset(args.data_dir, is_train=True, crop_size=args.crop_size)
    dataloader = dataset.get_dataloader(batch_size=args.batch_size, num_workers=0 if args.use_cpu else 4)
    
    # 输出数据集信息
    print(f"数据集大小: {len(dataset)}张图像")
    print(f"批次大小: {args.batch_size}")
    print(f"每轮迭代数: {len(dataloader)}")
    
    # 创建模型
    model = RAUNA(stages=args.stages, channels=args.channels).to(device)
    
    # 打印模型结构
    total_params = sum(p.numel() for p in model.parameters())
    print(f"模型参数总数: {total_params/1e6:.2f}M")
    
    # 创建损失函数
    dec_criterion = DecNetLoss().to(device)
    adj_criterion = AdjNetLoss().to(device)
    
    # 创建优化器
    dec_optimizer = optim.Adam(model.decnet.parameters(), lr=args.lr_dec)
    adj_optimizer = optim.Adam(model.adjnet.parameters(), lr=args.lr_adj)
    
    # 初始化起始轮次
    start_epoch = 0
    
    # 如果恢复训练
    if args.resume:
        if os.path.isfile(args.resume):
            print(f"加载检查点: {args.resume}")
            checkpoint = torch.load(args.resume, map_location=device)
            model.load_state_dict(checkpoint['model'])
            dec_optimizer.load_state_dict(checkpoint['dec_optimizer'])
            adj_optimizer.load_state_dict(checkpoint['adj_optimizer'])
            start_epoch = checkpoint['epoch']
            print(f"从第 {start_epoch} 轮恢复训练")
        else:
            print(f"未找到检查点: {args.resume}")
    
    # 训练循环
    for epoch in range(start_epoch, args.epochs):
        # 训练分解网络
        dec_loss = train_decomposition(
            model, 
            dataloader, 
            dec_optimizer, 
            dec_criterion, 
            device, 
            epoch, 
            args.epochs, 
            args.log_interval,
            args.accumulation_steps,
            args.use_mixed_precision
        )
        
        # 清理内存
        clear_gpu_memory()
        
        # 训练调整网络
        adj_loss = train_adjustment(
            model, 
            dataloader, 
            adj_optimizer, 
            adj_criterion, 
            device, 
            epoch, 
            args.epochs, 
            args.log_interval,
            args.accumulation_steps,
            args.use_mixed_precision
        )
        
        # 清理内存
        clear_gpu_memory()
        
        # 打印训练信息
        print(f"Epoch {epoch}/{args.epochs} | Dec Loss: {dec_loss:.4f} | Adj Loss: {adj_loss:.4f}")
        
        # 保存模型
        if (epoch + 1) % args.save_interval == 0:
            save_path = os.path.join(args.save_dir, f"rauna_epoch_{epoch+1}.pth")
            torch.save({
                'epoch': epoch + 1,
                'model': model.state_dict(),
                'dec_optimizer': dec_optimizer.state_dict(),
                'adj_optimizer': adj_optimizer.state_dict(),
                'dec_loss': dec_loss,
                'adj_loss': adj_loss
            }, save_path)
            print(f"模型已保存至: {save_path}")
    
    # 保存最终模型
    save_path = os.path.join(args.save_dir, "rauna_final.pth")
    torch.save({
        'epoch': args.epochs,
        'model': model.state_dict(),
        'dec_optimizer': dec_optimizer.state_dict(),
        'adj_optimizer': adj_optimizer.state_dict()
    }, save_path)
    print(f"最终模型已保存至: {save_path}")

if __name__ == "__main__":
    main() 