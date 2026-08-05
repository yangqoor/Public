#!/usr/bin/env python

import getopt
import numpy as np
import PIL
import PIL.Image
import sys
import torch
import torch.nn.functional as F
import cv2
import os
from typing import Tuple, Optional

##########################################################
# HED边缘检测模型（基于您提供的代码）
##########################################################

torch.set_grad_enabled(False)
torch.backends.cudnn.enabled = True

class HEDNetwork(torch.nn.Module):
    def __init__(self, model_path: Optional[str] = None):
        super().__init__()

        # VGG风格的编码器部分
        self.netVggOne = torch.nn.Sequential(
            torch.nn.Conv2d(in_channels=3, out_channels=64, kernel_size=3, stride=1, padding=1),
            torch.nn.ReLU(inplace=False),
            torch.nn.Conv2d(in_channels=64, out_channels=64, kernel_size=3, stride=1, padding=1),
            torch.nn.ReLU(inplace=False)
        )

        self.netVggTwo = torch.nn.Sequential(
            torch.nn.MaxPool2d(kernel_size=2, stride=2),
            torch.nn.Conv2d(in_channels=64, out_channels=128, kernel_size=3, stride=1, padding=1),
            torch.nn.ReLU(inplace=False),
            torch.nn.Conv2d(in_channels=128, out_channels=128, kernel_size=3, stride=1, padding=1),
            torch.nn.ReLU(inplace=False)
        )

        self.netVggThr = torch.nn.Sequential(
            torch.nn.MaxPool2d(kernel_size=2, stride=2),
            torch.nn.Conv2d(in_channels=128, out_channels=256, kernel_size=3, stride=1, padding=1),
            torch.nn.ReLU(inplace=False),
            torch.nn.Conv2d(in_channels=256, out_channels=256, kernel_size=3, stride=1, padding=1),
            torch.nn.ReLU(inplace=False),
            torch.nn.Conv2d(in_channels=256, out_channels=256, kernel_size=3, stride=1, padding=1),
            torch.nn.ReLU(inplace=False)
        )

        self.netVggFou = torch.nn.Sequential(
            torch.nn.MaxPool2d(kernel_size=2, stride=2),
            torch.nn.Conv2d(in_channels=256, out_channels=512, kernel_size=3, stride=1, padding=1),
            torch.nn.ReLU(inplace=False),
            torch.nn.Conv2d(in_channels=512, out_channels=512, kernel_size=3, stride=1, padding=1),
            torch.nn.ReLU(inplace=False),
            torch.nn.Conv2d(in_channels=512, out_channels=512, kernel_size=3, stride=1, padding=1),
            torch.nn.ReLU(inplace=False)
        )

        self.netVggFiv = torch.nn.Sequential(
            torch.nn.MaxPool2d(kernel_size=2, stride=2),
            torch.nn.Conv2d(in_channels=512, out_channels=512, kernel_size=3, stride=1, padding=1),
            torch.nn.ReLU(inplace=False),
            torch.nn.Conv2d(in_channels=512, out_channels=512, kernel_size=3, stride=1, padding=1),
            torch.nn.ReLU(inplace=False),
            torch.nn.Conv2d(in_channels=512, out_channels=512, kernel_size=3, stride=1, padding=1),
            torch.nn.ReLU(inplace=False)
        )

        # 侧输出层（用于多尺度特征融合）
        self.netScoreOne = torch.nn.Conv2d(in_channels=64, out_channels=1, kernel_size=1, stride=1, padding=0)
        self.netScoreTwo = torch.nn.Conv2d(in_channels=128, out_channels=1, kernel_size=1, stride=1, padding=0)
        self.netScoreThr = torch.nn.Conv2d(in_channels=256, out_channels=1, kernel_size=1, stride=1, padding=0)
        self.netScoreFou = torch.nn.Conv2d(in_channels=512, out_channels=1, kernel_size=1, stride=1, padding=0)
        self.netScoreFiv = torch.nn.Conv2d(in_channels=512, out_channels=1, kernel_size=1, stride=1, padding=0)

        # 特征融合层
        self.netCombine = torch.nn.Sequential(
            torch.nn.Conv2d(in_channels=5, out_channels=1, kernel_size=1, stride=1, padding=0),
            torch.nn.Sigmoid()
        )

        # 加载预训练模型
        if model_path and os.path.exists(model_path):
            self.load_model(model_path)
        else:
            print("警告: 未提供模型路径，自动下载预训练模型...")
            self.load_state_dict({ strKey.replace('module', 'net'): tenWeight for strKey, tenWeight in torch.hub.load_state_dict_from_url(url='http://content.sniklaus.com/github/pytorch-hed/network-' + 'bsds500' + '.pytorch', file_name='hed-' + 'bsds500').items() })

    def load_model(self, model_path: str):
        """加载预训练模型权重"""
        try:
            checkpoint = torch.load(model_path, map_location='cpu')
            
            # 处理键名不匹配的情况（将module替换为net）
            if any('module' in key for key in checkpoint.keys()):
                checkpoint = {key.replace('module', 'net'): value for key, value in checkpoint.items()}
            
            # 严格模式加载，如果键不匹配会报错
            self.load_state_dict(checkpoint, strict=True)
            print(f"模型权重加载成功: {model_path}")
        except Exception as e:
            print(f"模型加载失败: {e}")
            # 如果是键不匹配，尝试非严格模式加载
            try:
                self.load_state_dict(checkpoint, strict=False)
                print("使用非严格模式加载成功")
            except Exception as e2:
                print(f"非严格模式加载也失败: {e2}")

    def forward(self, tenInput):
        # HED特定的预处理
        tenInput = tenInput * 255.0
        tenInput = tenInput - torch.tensor(
            data=[104.00698793, 116.66876762, 122.67891434], 
            dtype=tenInput.dtype, device=tenInput.device
        ).view(1, 3, 1, 1)

        # 前向传播获取多尺度特征
        tenVggOne = self.netVggOne(tenInput)
        tenVggTwo = self.netVggTwo(tenVggOne)
        tenVggThr = self.netVggThr(tenVggTwo)
        tenVggFou = self.netVggFou(tenVggThr)
        tenVggFiv = self.netVggFiv(tenVggFou)

        # 侧输出
        tenScoreOne = self.netScoreOne(tenVggOne)
        tenScoreTwo = self.netScoreTwo(tenVggTwo)
        tenScoreThr = self.netScoreThr(tenVggThr)
        tenScoreFou = self.netScoreFou(tenVggFou)
        tenScoreFiv = self.netScoreFiv(tenVggFiv)

        # 上采样到原始尺寸
        tenScoreOne = F.interpolate(tenScoreOne, size=tenInput.shape[2:], mode='bilinear', align_corners=False)
        tenScoreTwo = F.interpolate(tenScoreTwo, size=tenInput.shape[2:], mode='bilinear', align_corners=False)
        tenScoreThr = F.interpolate(tenScoreThr, size=tenInput.shape[2:], mode='bilinear', align_corners=False)
        tenScoreFou = F.interpolate(tenScoreFou, size=tenInput.shape[2:], mode='bilinear', align_corners=False)
        tenScoreFiv = F.interpolate(tenScoreFiv, size=tenInput.shape[2:], mode='bilinear', align_corners=False)

        # 特征融合
        tenCombined = torch.cat([tenScoreOne, tenScoreTwo, tenScoreThr, tenScoreFou, tenScoreFiv], 1)
        return self.netCombine(tenCombined)

##########################################################
# 文档裁切服务
##########################################################

class DocumentCropper:
    def __init__(self, model_path: str, device: str = 'cuda'):
        self.device = device if torch.cuda.is_available() and device == 'cuda' else 'cpu'
        self.model = HEDNetwork(model_path).to(self.device)
        self.model.eval()
        print(f"文档裁切服务初始化完成，设备: {self.device}")

    def preprocess_image(self, image_path: str) -> torch.Tensor:
        """图像预处理"""
        # 读取图像
        if isinstance(image_path, str):
            image = PIL.Image.open(image_path).convert('RGB')
        else:
            image = image_path
            
        # 转换为numpy数组并调整通道顺序
        image_np = np.array(image)[:, :, ::-1]  # RGB to BGR
        image_np = image_np.transpose(2, 0, 1).astype(np.float32) * (1.0 / 255.0)
        
        return torch.FloatTensor(image_np)

    def detect_edges(self, tenInput: torch.Tensor) -> np.ndarray:
        """边缘检测"""
        with torch.no_grad():
            # 添加batch维度并转移到设备
            tenInput = tenInput.unsqueeze(0).to(self.device)
            tenOutput = self.model(tenInput)
            
            # 转换为numpy数组
            edge_map = tenOutput[0, 0].cpu().numpy()
            return edge_map

    def find_content_boundary(self, edge_map: np.ndarray, threshold: float = 0.5, min_area_ratio: float = 0.50) -> Optional[Tuple[int, int, int, int]]:
        """
        基于边缘图寻找内容边界
        
        参数:
            edge_map: 边缘检测结果图
            threshold: 边缘二值化阈值
            min_area_ratio: 轮廓最小面积与整个图片面积的比率（默认0.75即75%）
        
        返回:
            文档边界框 (x1, y1, x2, y2) 或 None（未找到合适轮廓时）
        """
        # 二值化
        binary_edges = (edge_map > threshold).astype(np.uint8) * 255
        cv2.imwrite('binary_edges.png', binary_edges)
        
        # 形态学操作连接断开的边缘
        kernel = np.ones((5, 5), np.uint8)
        binary_edges = cv2.morphologyEx(binary_edges, cv2.MORPH_CLOSE, kernel)
        
        # 查找轮廓 [1,3](@ref)
        contours, _ = cv2.findContours(binary_edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        
        if not contours:
            return None
        
        # 计算整个图片的面积
        height, width = edge_map.shape
        image_area = height * width
        min_area_threshold = image_area * min_area_ratio
        
        # 筛选出面积大于阈值的轮廓 [3,6](@ref)
        large_contours = []
        for contour in contours:
            area = cv2.contourArea(contour)
            if area >= min_area_threshold:
                large_contours.append(contour)
        
        if not large_contours:
            # 如果没有轮廓满足面积要求，退回使用最大轮廓
            print("警告：未找到面积大于{}%的轮廓，使用最大轮廓".format(min_area_ratio*100))
            largest_contour = max(contours, key=cv2.contourArea)
            large_contours = [largest_contour]
        
        # 从符合条件的轮廓中选择最合适的（面积最大的）[5](@ref)
        selected_contour = max(large_contours, key=cv2.contourArea)
        
        # 计算最小外接矩形 [1,4](@ref)
        x, y, w, h = cv2.boundingRect(selected_contour)
        
        # 返回边界框 (x1, y1, x2, y2)
        return (x, y, x + w, y + h)
    

    def crop_document(self, image_path: str, output_path: Optional[str] = None, 
                     margin: int = 10, threshold: float = 0.8) -> np.ndarray:
        """完整的文档裁切流程"""
        print(f"处理图像: {image_path}")
        
        # 预处理
        tenInput = self.preprocess_image(image_path)
        original_image = cv2.imread(image_path) if isinstance(image_path, str) else image_path
        h, w = original_image.shape[:2]
        
        # 边缘检测
        print("正在进行边缘检测...")
        edge_map = self.detect_edges(tenInput)
        cv2.imwrite('out.png', (edge_map * 255).astype(np.uint8))
        
        # 寻找内容边界
        print("计算内容边界...")
        boundary = self.find_content_boundary(edge_map, threshold)
        
        if boundary is None:
            print("未检测到有效边界，返回原图")
            return original_image
        
        x1, y1, x2, y2 = boundary
        
        # 添加边距
        x1 = max(0, x1 - margin)
        y1 = max(0, y1 - margin)
        x2 = min(w, x2 + margin)
        y2 = min(h, y2 + margin)
        
        # 确保边界有效
        if x2 <= x1 or y2 <= y1:
            print("无效的边界框，返回原图")
            return original_image
        
        # 裁切图像
        cropped_image = original_image[y1:y2, x1:x2]
        
        # 保存结果
        if output_path:
            cv2.imwrite(output_path, cropped_image)
            print(f"裁切结果已保存: {output_path}")
        
        print(f"裁切完成: 原图尺寸 {w}x{h} -> 裁切后 {x2-x1}x{y2-y1}")
        return cropped_image

    def process_image_list(self, image_list_file: str, output_dir: str = './output'):
        """批量处理图像列表"""
        if not os.path.exists(output_dir):
            os.makedirs(output_dir)
        
        with open(image_list_file, 'r') as f:
            image_paths = [line.strip() for line in f if line.strip()]
        
        for i, image_path in enumerate(image_paths):
            if not os.path.exists(image_path):
                print(f"图像文件不存在: {image_path}")
                continue
                
            output_filename = f"cropped_{os.path.basename(image_path)}"
            output_path = os.path.join(output_dir, output_filename)
            
            try:
                self.crop_document(image_path, output_path)
                print(f"进度: {i+1}/{len(image_paths)}")
            except Exception as e:
                print(f"处理图像失败 {image_path}: {e}")

##########################################################
# 主函数和命令行接口
##########################################################

def main():
    # 默认参数
    model_path = 'network-bsds500.pytorch'
    input_path = './images/t1_2.jpg'
    # input_path = 'cropped_output.png'
    output_path = './cropped_output.png'
    image_list_file = None
    import time
    start_time = time.time()


    # 解析命令行参数
    try:
        opts, args = getopt.getopt(sys.argv[1:], 'm:i:o:l:', 
                                  ['model=', 'input=', 'output=', 'list='])
    except getopt.GetoptError:
        print('用法: python document_cropper.py -m <model_path> -i <input_image> -o <output_image>')
        print('或: python document_cropper.py -m <model_path> -l <image_list_file>')
        sys.exit(2)
    
    for opt, arg in opts:
        if opt in ('-m', '--model'):
            model_path = arg
        elif opt in ('-i', '--input'):
            input_path = arg
        elif opt in ('-o', '--output'):
            output_path = arg
        elif opt in ('-l', '--list'):
            image_list_file = arg
    
    # 初始化裁切服务
    cropper = DocumentCropper(model_path)
    
    if image_list_file:
        # 批量处理模式
        cropper.process_image_list(image_list_file)
    else:
        # 单张图像处理模式
        cropper.crop_document(input_path, output_path, threshold=0.7)

    end_time = time.time()
    print("耗时：", end_time - start_time)

if __name__ == '__main__':
    main()