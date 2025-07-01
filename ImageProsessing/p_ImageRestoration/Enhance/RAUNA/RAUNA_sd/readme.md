# RAUNA_TNN
# 训练命令
python.exe main.py --stage 17 --num_L 29 --num_R 32 --epochs 10  --ni --config imagenet_64.yml --path_y imagenet --eta 0.85 --deg "denoising" --deg_scale 4.0 --sigma_y 0


# 测试命令
python.exe main.py --stage 17 --num_L 29 --num_R 32 --test_only --epochs 10  --ni --config imagenet_64.yml --path_y imagenet --eta 0.85 --deg "denoising" --deg_scale 4.0 --sigma_y 0




注：	--deg 参数是zero论文的，根据不同需求选用不同参数，这里用的denoising


| **退化模式**               | **描述**                                                                 | **关键参数/配置**                                                                 | **相关操作类**                     |
|---------------------------|-------------------------------------------------------------------------|---------------------------------------------------------------------------------|-----------------------------------|
| `cs_walshhadamard`        | 基于Walsh-Hadamard变换的压缩感知                                         | `compress_by`（压缩比例，由`args.deg_scale`计算）                                 | `WalshHadamardCS`                |
| `cs_blockbased`           | 块状压缩感知                                                            | `cs_ratio`（压缩比例，直接使用`args.deg_scale`）                                  | `CS`                             |
| `inpainting`              | 图像修复（部分像素缺失）                                                 | 从文件`mask.npy`加载掩码，缺失像素位置通过`missing_r/g/b`计算                      | `Inpainting`                     |
| `denoising`               | 去噪                                                                    | 无显式参数                                                                       | `Denoising`                      |
| `colorization`            | 灰度图上色                                                              | 无显式参数                                                                       | `Colorization`                   |
| `sr_averagepooling`       | 基于平均池化的超分辨率                                                   | `blur_by`（下采样比例，由`args.deg_scale`指定）                                   | `SuperResolution`                |
| `sr_bicubic`              | 基于双三次插值的超分辨率                                                 | `factor`（缩放因子，由`args.deg_scale`指定），自定义`bicubic_kernel`生成卷积核     | `SRConv`                         |
| `deblur_uni`              | 均匀模糊（均值滤波）去模糊                                               | 固定9x1均匀核（`[1/9, ..., 1/9]`）                                               | `Deblurring`                     |
| `deblur_gauss`            | 高斯模糊去模糊                                                          | 基于`sigma=10`生成5x1高斯核                                                      | `Deblurring`                     |
| `deblur_aniso`            | 各向异性模糊去模糊（2D核）                                               | 水平/垂直方向分别用`sigma=20`和`sigma=1`生成9x1高斯核                             | `Deblurring2D`                   |
