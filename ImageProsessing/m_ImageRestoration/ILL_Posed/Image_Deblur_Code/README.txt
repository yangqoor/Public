This package contains an implementation of the image deblurring algorithm described in the paper:
"An Adaptive Iterative Algorithm for Motion Deblurring based on Salient Intensity Prior". 
Author: Hancheng Yu (yuhc@nuaa.edu.cn), Wenkai Wang, and Wenshi Fan
----------------
How to use
----------------
The code is tested in MATLAB 2015b(64bit) and 2016a(64bit) under the MS Windows 7 64bit version with an Intel Core i7-6700 CPU and 4GB RAM.
The PSNR of Koehler's database is test in MATLAB 2015b(64bit).
----------------
1. unpack the package
2. include code/subdirectory in your Matlab path
3. Run "demo_deblurring.m" to try the examples included in this package.
----------------
The filename is the only parameter need to be specified by users.
----------------
For the whole non-blind deblurring algorithm, we use for reference existing methods (e.g., [1, 2, 3, 4, 5]) to genetate the final results:
[1] J. Pan, Z. Hu, Z. Su, and M.-H. Yang, Deblurring Text Images via L0-Regularized Intensity and Gradient Prior. CVPR 2014.
[2] J. Pan, D. Sun, H. Pfister, and M.-H. Yang, Blind Image Deblurring Using Dark Channel Prior. CVPR2016.
[3] S. Cho, J. Wang, and S. Lee, Handling outliers in non-blind image deconvolution. ICCV 2011.
[4] O. Whyte, J. Sivic, and A. Zisserman, Deblurring shaken and partially saturated images. ICCV Workshops 2011
[5] Z. Hu, S. Cho, J. Wang, and M.-H. Yang, Deblurring lowlight images with light streaks. CVPR 2014.
----------------
Please cite our paper if using the code to generate data (e.g., images, tables of processing times, etc.) in an academic publication.
For algorithmic details, please refer to our paper or e-mail us.
Thank you.