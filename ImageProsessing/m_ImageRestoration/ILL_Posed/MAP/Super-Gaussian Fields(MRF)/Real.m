%Deblurring Natural Image Using Super-Gaussian Fields ECCV 2018

%input:
% sig_noise - noise level
% precision - initial precision for super gaussian fields.
% sizeL     - kernel size
% x         - (optional) original sharp image, just used for error evaluation.
% y         - blurred image.
% iterN     - the number of iterations for optimizting intermediate x using
% CG

%output: 
% k         - estimated kernel
% ex        - estimated latent image  
% ssde      - error between estimated image and sharp reference.
%
%Writen by: Yuhang Liu, Email:liuyuhang@whu.edu.cn (c)
    

% Note: 
% 1) this algorithm sometimes may converge to an incorrect result. 
% When this case occurs, please re-try to deblur with a slightly changed parameters: 
% e.g., 
%  a: using different kernel sizes;
%  b: using different precision, e.g., setting 1e4 for image 2 kernel 8 in Kohler's dataset 
% 2) Normally, setting iterN = 40 can obtain satisfactory result and better running
%    time, but setting larger value, e.g., iterN = 150, is necessary for some special images.
%    e.g., for image 4 kernle 4 in levin's dataset.  
% any problems, please contact Yuhang Liu, Email:liuyuhang@whu.edu.cn.

sig_noise=0.002;
iterN = 50;
precision = 1e3;

%y = im2double(imread('skycrop.jpg'));sizeL=30;
y = im2double(imread('real_blur_img3.png'));sizeL=30;
y = rgb2gray(y);

      
[k,ex,ssde]=Deblurring(y,sizeL,sizeL,sig_noise,iterN,precision);

 