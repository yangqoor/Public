import os
import torch
import numpy as np
from torch.utils.data import Dataset, DataLoader
from PIL import Image
import torchvision.transforms as transforms
import random

class LOLDataset(Dataset):
    """
    低光图像数据集（LOL数据集）
    包含真实低光和正常光照图像对
    """
    def __init__(self, root_dir, is_train=True, crop_size=256, augment=True):
        """
        Args:
            root_dir: 数据集根目录路径
            is_train: 是否为训练集
            crop_size: 随机裁剪大小
            augment: 是否使用数据增强
        """
        self.root_dir = root_dir
        self.is_train = is_train
        self.crop_size = crop_size
        self.augment = augment
        
        # 设置子目录名 - 修改以适应当前数据集结构
        # 原始代码
        # self.low_dir = 'low' if is_train else 'eval15/low'
        # self.normal_dir = 'normal' if is_train else 'eval15/normal'
        
        # 适应当前数据集结构
        self.low_dir = 'our485/low' if is_train else 'eval15/low'
        self.normal_dir = 'our485/high' if is_train else 'eval15/high'
        
        # 获取所有图像文件名
        self.file_list = []
        low_path = os.path.join(root_dir, self.low_dir)
        
        if os.path.exists(low_path):
            for filename in os.listdir(low_path):
                if self._is_image_file(filename):
                    self.file_list.append(filename)
        
        # 基本变换
        self.transform = transforms.Compose([
            transforms.ToTensor()
        ])
        
    def _is_image_file(self, filename):
        """检查文件是否为图像"""
        return any(filename.endswith(extension) for extension in 
                   ['.png', '.jpg', '.jpeg', '.PNG', '.JPG', '.JPEG'])
    
    def __len__(self):
        return len(self.file_list)
    
    def __getitem__(self, idx):
        """获取图像对"""
        if torch.is_tensor(idx):
            idx = idx.tolist()
            
        # 获取文件名
        filename = self.file_list[idx]
        
        # 读取低光图像
        low_path = os.path.join(self.root_dir, self.low_dir, filename)
        low_img = Image.open(low_path).convert('RGB')
        
        # 读取正常光照图像
        normal_path = os.path.join(self.root_dir, self.normal_dir, filename)
        normal_img = Image.open(normal_path).convert('RGB')
        
        # 应用数据增强
        if self.augment and self.is_train:
            # 获取随机裁剪的参数
            i, j, h, w = self._get_random_crop_params(low_img)
            
            # 应用相同的裁剪参数到两张图像
            low_img = transforms.functional.crop(low_img, i, j, h, w)
            normal_img = transforms.functional.crop(normal_img, i, j, h, w)
            
            # 随机翻转
            if random.random() > 0.5:
                low_img = transforms.functional.hflip(low_img)
                normal_img = transforms.functional.hflip(normal_img)
                
            if random.random() > 0.5:
                low_img = transforms.functional.vflip(low_img)
                normal_img = transforms.functional.vflip(normal_img)
                
            # 随机旋转
            angle = random.choice([0, 90, 180, 270])
            if angle != 0:
                low_img = transforms.functional.rotate(low_img, angle)
                normal_img = transforms.functional.rotate(normal_img, angle)
        
        # 转换为tensor
        low_tensor = self.transform(low_img)
        normal_tensor = self.transform(normal_img)
        
        return {
            'low': low_tensor, 
            'normal': normal_tensor,
            'filename': filename
        }
    
    def _get_random_crop_params(self, img):
        """获取随机裁剪参数"""
        w, h = img.size
        th, tw = self.crop_size, self.crop_size
        
        if w == tw and h == th:
            return 0, 0, h, w
            
        if w < tw or h < th:
            # 如果图像小于裁剪大小，先调整图像大小
            img = transforms.Resize((max(th, h), max(tw, w)))(img)
            w, h = img.size
        
        i = random.randint(0, h - th) if h > th else 0
        j = random.randint(0, w - tw) if w > tw else 0
        
        return i, j, th, tw
    
    def get_dataloader(self, batch_size=8, shuffle=True, num_workers=4):
        """创建数据加载器"""
        return DataLoader(
            self,
            batch_size=batch_size,
            shuffle=shuffle,
            num_workers=num_workers
        )

class PairedDataset(Dataset):
    """
    通用配对图像数据集
    支持任意配对的低光/正常光照图像
    """
    def __init__(self, low_dir, normal_dir, crop_size=256, augment=True):
        """
        Args:
            low_dir: 低光图像目录
            normal_dir: 正常光照图像目录
            crop_size: 随机裁剪大小
            augment: 是否使用数据增强
        """
        self.low_dir = low_dir
        self.normal_dir = normal_dir
        self.crop_size = crop_size
        self.augment = augment
        
        # 获取所有低光图像文件名
        self.file_list = []
        for filename in os.listdir(low_dir):
            if self._is_image_file(filename):
                # 检查是否存在对应的正常光照图像
                normal_path = os.path.join(normal_dir, filename)
                if os.path.exists(normal_path):
                    self.file_list.append(filename)
        
        # 基本变换
        self.transform = transforms.Compose([
            transforms.ToTensor()
        ])
        
    def _is_image_file(self, filename):
        """检查文件是否为图像"""
        return any(filename.endswith(extension) for extension in 
                   ['.png', '.jpg', '.jpeg', '.PNG', '.JPG', '.JPEG'])
    
    def __len__(self):
        return len(self.file_list)
    
    def __getitem__(self, idx):
        """获取图像对"""
        if torch.is_tensor(idx):
            idx = idx.tolist()
            
        # 获取文件名
        filename = self.file_list[idx]
        
        # 读取低光图像
        low_path = os.path.join(self.low_dir, filename)
        low_img = Image.open(low_path).convert('RGB')
        
        # 读取正常光照图像
        normal_path = os.path.join(self.normal_dir, filename)
        normal_img = Image.open(normal_path).convert('RGB')
        
        # 应用数据增强
        if self.augment:
            # 获取随机裁剪的参数
            i, j, h, w = self._get_random_crop_params(low_img)
            
            # 应用相同的裁剪参数到两张图像
            low_img = transforms.functional.crop(low_img, i, j, h, w)
            normal_img = transforms.functional.crop(normal_img, i, j, h, w)
            
            # 随机翻转
            if random.random() > 0.5:
                low_img = transforms.functional.hflip(low_img)
                normal_img = transforms.functional.hflip(normal_img)
                
            if random.random() > 0.5:
                low_img = transforms.functional.vflip(low_img)
                normal_img = transforms.functional.vflip(normal_img)
                
            # 随机旋转
            angle = random.choice([0, 90, 180, 270])
            if angle != 0:
                low_img = transforms.functional.rotate(low_img, angle)
                normal_img = transforms.functional.rotate(normal_img, angle)
        
        # 转换为tensor
        low_tensor = self.transform(low_img)
        normal_tensor = self.transform(normal_img)
        
        return {
            'low': low_tensor, 
            'normal': normal_tensor,
            'filename': filename
        }
    
    def _get_random_crop_params(self, img):
        """获取随机裁剪参数"""
        w, h = img.size
        th, tw = self.crop_size, self.crop_size
        
        if w == tw and h == th:
            return 0, 0, h, w
            
        if w < tw or h < th:
            # 如果图像小于裁剪大小，先调整图像大小
            img = transforms.Resize((max(th, h), max(tw, w)))(img)
            w, h = img.size
        
        i = random.randint(0, h - th) if h > th else 0
        j = random.randint(0, w - tw) if w > tw else 0
        
        return i, j, th, tw
    
    def get_dataloader(self, batch_size=8, shuffle=True, num_workers=4):
        """创建数据加载器"""
        return DataLoader(
            self,
            batch_size=batch_size,
            shuffle=shuffle,
            num_workers=num_workers
        ) 