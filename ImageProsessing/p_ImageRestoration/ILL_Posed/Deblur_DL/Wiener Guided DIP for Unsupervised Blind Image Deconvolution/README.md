## Wiener Guided DIP for Unsupervised Blind Image Deconvolution


### Introduction
Blind deconvolution is an ill-posed problem arising in various fields ranging from microscopy to astronomy. The ill-posed nature of the problem requires adequate priors to arrive to a desirable solution. Recently, it has been shown that deep learning architectures can serve as an image generation prior during unsupervised blind deconvolution optimization, however often exhibiting a performance fluctuation even on a single image. We propose to use Wiener-deconvolution to guide the image generator during optimization by providing it a sharpened version of the blurry image using an auxiliary kernel estimate starting from a Gaussian. We observe that the high-frequency artifacts of deconvolution are reproduced with a delay compared to low-frequency features. In addition, the image generator reproduces low-frequency features of the deconvolved image faster than that of a blurry image. We embed the computational process in a constrained optimization framework and show that the proposed method yields higher stability and performance across multiple datasets.


## Datasets

Only one example image of each dataset is included in the zip file from each of the datasets listed in the paper due to size limitations. To download the full datasets please do it here:
- Levin et al.[1] dataset included, benchmark results provided by Ren et al.[2]: [OneDrive](https://1drv.ms/u/s!An-BNLJWOClliGSEa6QY9TVedqJH?e=8vSWld).
- Lai et al.[3], provided by Ren et al.[2]: [OneDrive](https://1drv.ms/u/s!An-BNLJWOClliGSEa6QY9TVedqJH?e=8vSWld).
- Microscopy dataset: Included in the zip file
- Sun dataset provided by Sun et al.[4]: https://cs.brown.edu/people/lbsun/deblur2013/deblur2013iccp.html
- Real-world images, provided by Lai et al.[2]: http://vllab.ucmerced.edu/wlai24/cvpr16_deblur_study/

The blurred version of the datasets should then be placed in the respective dataset folder.


## Getting Started

### 1. Run W-DIP


-(1) Create the correct environment
```bash
conda create -n wdip python=3.8
conda activate wdip
```
Additional requirements are:
- PyTorch >= 1.9
- tqdm, opencv-python, skimage


-(2) To run W-DIP. Select the dataset to run on.
```bash
python WDIP.py --data_path datasets/levin/blur/ --save_path results/levin/WDIP --ksize_path kernel_estimates/levin_kernel.yaml --dataset_name levin --channels 1

python WDIP.py --data_path datasets/lai/blur/ --save_path results/lai/WDIP --ksize_path kernel_estimates/lai_kernel.yaml --dataset_name lai --channels 3

python WDIP.py --num_iter 2000 --data_path datasets/micro_bad/blur/ --save_path results/micro_bad/WDIP --ksize_path kernel_estimates/micro_bad_kernel.yaml --dataset_name micro_bad --channels 1 --Gsize 20
python WDIP.py --num_iter 2000 --data_path datasets/micro_bad/blur/ --save_path results/micro_bad/WDIP --ksize_path kernel_estimates/micro_bad_kernel.yaml --dataset_name micro_bad --channels 1 --Gsize 20 --wa 1e-2 --wb 1e-1 --wk 1e-2

python WDIP.py --data_path datasets/sun/blur/ --save_path results/sun/WDIP --ksize_path kernel_estimates/sun_kernel.yaml --dataset_name sun --channels 1

python WDIP.py --data_path datasets/real/blur/ --save_path results/real/WDIP --dataset_name real --channels 3
```

-(3) To run SelfDeblur the same commands can be used but all the weights of the regularization should be set to zero as shown below.
```bash
python WDIP.py --data_path datasets/levin/blur/ --save_path results/levin/SD --ksize_path kernel_estimates/levin_kernel.yaml --dataset_name levin --channels 1 --wa 0 --wb 0 --wk 0

python WDIP.py --data_path datasets/lai/blur/ --save_path results/lai/SD --ksize_path kernel_estimates/lai_kernel.yaml --dataset_name lai --channels 3 --wa 0 --wb 0 --wk 0

python WDIP.py --num_iter 2000 --data_path datasets/micro_bad/blur/ --save_path results/micro_bad/SD --ksize_path kernel_estimates/micro_bad_kernel.yaml --dataset_name micro_bad --channels 1 --wa 0 --wb 0 --wk 0

python WDIP.py --data_path datasets/sun/blur/ --save_path results/sun/SD --ksize_path kernel_estimates/sun_kernel.yaml --dataset_name sun --channels 1 --wa 0 --wb 0 --wk 0

python WDIP.py --data_path datasets/real/blur/ --save_path results/real/SD --ksize_path kernel_estimates/real_kernel.yaml --dataset_name real --channels 3 --wa 0 --wb 0 --wk 0
```

### 2. Evaluation metrics

To run the statistics for levin, sun and microscopy use the scripts provided in statistics.
 
To run the statistics for the Lai et. al.[3] dataset, please use the provided matlab script
```Matlab
 cd ./statistic
 run statistic_lai.m 
```

## References
[1] A. Levin, Y. Weiss, F. Durand, and W. T. Freeman. Understanding and evaluating blind deconvolution algorithms. In IEEE CVPR 2009. 

[2] D. Ren, K. Zhang, Q. Wang, and Q. Hu, W. Zuo. Neural Blind Deconvolution Using Deep Priors. In IEEE CVPR 2020.

[3] W.-S. Lai, J.-B. Huang, Z. Hu, N. Ahuja, and M.-H. Yang. A comparative study for single image blind deblurring. In IEEE CVPR 2016.

[4] L. Sun, S. Cho, J. Wang and J. Hays. Edge-based Blur Kernel Estimation Using Patch Priors. In IEEE ICCP 2013.




