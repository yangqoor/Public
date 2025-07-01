# RAUNA: 基于视网膜理论的算法展开和调整的低光图像增强

这是论文 **"Low-Light Image Enhancement by Retinex-Based Algorithm Unrolling and Adjustment"** 的PyTorch实现。

## 介绍

RAUNA（Retinex-based Algorithm Unrolling and Adjustment）是一个基于Retinex理论的低光图像增强框架，主要由三个部分组成：
1. 基于算法展开的分解网络（DecNet）：将低光图像分解为反射率和照明率
2. 调整网络（AdjNet）：通过考虑全局和局部亮度敏感度调整分解结果
3. 自监督微调策略：在测试阶段实现无需用户干预的参数调优

## 安装依赖

```bash
pip install torch torchvision opencv-python pillow numpy tqdm
```

可选（用于自监督微调中的去噪）：
```bash
pip install bm3d
```

## 目录结构

```
.
├── models/             # 模型定义
│   ├── __init__.py
│   └── rauna.py        # RAUNA模型
├── utils/              # 工具函数
│   ├── __init__.py
│   ├── losses.py       # 损失函数
│   └── fine_tuning.py  # 自监督微调工具
├── datasets/           # 数据集加载器
│   ├── __init__.py
│   └── lol_dataset.py  # LOL数据集
├── train.py            # 训练脚本
├── test.py             # 测试和评估脚本
└── README.md
```

## 使用方法

### 1. 训练模型

```bash
python train.py --data_dir ./data/LOL --batch_size 8 --epochs 100 --lr_dec 1e-4 --lr_adj 1e-3 --save_dir ./checkpoints
```

主要参数：
- `--data_dir`：LOL数据集路径
- `--batch_size`：批次大小
- `--epochs`：训练轮数
- `--lr_dec`：DecNet学习率
- `--lr_adj`：AdjNet学习率
- `--crop_size`：训练时的随机裁剪大小
- `--save_dir`：模型保存目录
- `--stages`：DecNet的算法展开阶段数（默认为17）

### 2. 测试模型

```bash
python test.py --input ./test_images/low_light.png --output ./results --model ./checkpoints/rauna_final.pth --fine_tune
```

主要参数：
- `--input`：输入低光图像或图像目录
- `--output`：输出结果保存目录
- `--model`：预训练模型路径
- `--fine_tune`：是否使用自监督微调（可选）
- `--fine_tune_steps`：微调步骤数（默认30）
- `--alpha`：全局亮度参数（默认0.5）
- `--save_components`：是否保存分解的组件（可选）

## 数据集

本实现使用LOL数据集（Low-Light dataset）进行训练和评估。LOL数据集包含485对低光/正常光照图像对，其中有真实和合成的图像。

您可以从以下位置下载LOL数据集：
- [LOL数据集](https://daooshee.github.io/BMVC2018website/)

## 引用

如果您使用了这个代码，请引用原论文：

```
@article{liu2023lie,
  title={Low-Light Image Enhancement by Retinex-Based Algorithm Unrolling and Adjustment},
  author={Liu, Xinyi and Xie, Qi and Zhao, Qian and Wang, Hong and Meng, Deyu},
  journal={IEEE Transactions on Neural Networks and Learning Systems},
  year={2023},
  publisher={IEEE}
}
```

## 许可证

MIT 