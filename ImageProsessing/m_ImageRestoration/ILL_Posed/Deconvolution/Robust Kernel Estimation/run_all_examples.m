clc;
clear;
close all;
%% ==Required input parameters for each example== %%
% The regularization weight in final non-blind deconvolution
% typically set as 1e-3,2e-3, 3e-3, 4e-3, 5e-3, or 6e-3;
opts.I_reg_wt = 5e-3;
% gamma correction: typically  set as 1.0
opts.gamma_correct = 1.0;
% maximum number of I/k alternations at each level (4 by defalut); 
opts.Ik_iter = 4;
%% ================================== %%
% display the intermdiate results at each iteration (1/0)
opts.display = 1;
%% Test examples
%%
% fn = 'images/test_blur.png'; opts.kernel_size = 23; 
% opts.I_reg_wt = 1e-3; opts.gamma_correct = 1.0;
%%
% fn = 'images/im01_ker04_blur_cor.png'; opts.kernel_size = 27;
% opts.I_reg_wt = 3e-3; opts.gamma_correct = 1.0;
%%
% fn = 'images/image_from_whyte.png'; opts.kernel_size = 65;
% opts.I_reg_wt = 5e-3; opts.gamma_correct = 1.0;
%%
% fn = 'images/IMG_0678_small.png'; opts.kernel_size = 77; 
% opts.I_reg_wt = 5e-3; opts.gamma_correct = 1.0;
%%
% fn = 'images/tree.png'; opts.kernel_size = 23; 
% opts.I_reg_wt = 5e-3; opts.gamma_correct = 1.0;
%% 
% fn = 'images/test_blurred_3.png'; opts.kernel_size = 31; 
% opts.I_reg_wt = 3e-3; opts.gamma_correct = 1.0;
%% 
% fn = 'images/car.png'; opts.kernel_size = 45; 
% opts.I_reg_wt = 3e-3; opts.gamma_correct = 1.0;
%% 
% fn = 'images/IMG_0691_small_patch_l_s1_gamma.png'; opts.kernel_size = 79; 
% opts.gamma_correct = 1.0; opts.I_reg_wt = 5e-3;
%%
% fn = 'images/test_11_blur.png'; opts.kernel_size = 25; 
% opts.gamma_correct = 1.0; opts.I_reg_wt = 3e-3;
%% 
% fn = 'images/wall.png'; opts.kernel_size = 55; 
% opts.gamma_correct = 1.0; opts.I_reg_wt = 1e-3;
%%
fn = 'images/fishes.jpg'; opts.kernel_size = 45;
opts.gamma_correct = 1.0; opts.I_reg_wt = 1e-3;
%%
% fn = 'images/toy.png'; opts.kernel_size = 95; 
% opts.gamma_correct = 1.0; opts.I_reg_wt = 1e-3;
%%
% fn = 'images/summerhouse.jpg'; opts.kernel_size = 93; 
% opts.gamma_correct = 1.0; opts.I_reg_wt = 1e-3;
%%
% fn = 'images/roma.png'; opts.kernel_size = 55; 
% opts.gamma_correct = 1.0; opts.I_reg_wt = 1e-3;
%% 
% fn = 'images/soldier.png'; opts.kernel_size = 27; 
% opts.gamma_correct = 1.0; opts.I_reg_wt = 1e-3;
%% 
% fn = 'images/IMG_0747_patch.png'; opts.kernel_size = 45; 
% opts.gamma_correct = 2.2;  opts.I_reg_wt = 5e-3;
%%
% fn = 'images/image.jpg'; opts.kernel_size = 35; 
% opts.gamma_correct = 1.0;  opts.I_reg_wt = 6e-3;
%%
% fn = 'images/car_whyte.png'; opts.kernel_size = 35; 
% opts.gamma_correct = 1.0;  opts.I_reg_wt = 3e-3;
%% 
% fn = 'images/text_images.png'; opts.kernel_size = 115; 
% opts.gamma_correct = 1.0;  opts.I_reg_wt = 3e-3;
%%
% fn = 'images/IMG_0638_small.png'; opts.kernel_size = 77; 
% opts.I_reg_wt = 5e-3; opts.gamma_correct = 1.0;
%
%%
% fn = 'images/im01_ker08_blur_cor_2.png'; opts.kernel_size = 23; 
% opts.I_reg_wt = 5e-3; opts.gamma_correct = 1.0;
%%
% fn = 'images/my_test_car6.png'; opts.kernel_size = 69; 
% opts.I_reg_wt = 5e-3; opts.gamma_correct = 2.2;
%% 
% fn = 'images/real_blur_img3.png'; opts.kernel_size = 25; 
% opts.I_reg_wt = 2e-3; opts.gamma_correct = 1.0;
%%
% fn = 'images/boat_input.png'; opts.kernel_size = 45; 
% opts.I_reg_wt = 3e-3; opts.gamma_correct = 1.0;
%%
% fn = 'images/0015_blur65.png'; opts.kernel_size = 65; 
% opts.I_reg_wt = 1e-3; opts.gamma_correct = 1.0;
%%
% fn = 'images/water_machine.png'; opts.kernel_size = 45; 
% opts.I_reg_wt = 1e-3; opts.gamma_correct = 1.0;
%%
% fn = 'images/IMG_0664_small_patch.png'; opts.kernel_size = 69; 
% opts.I_reg_wt = 5e-3; opts.gamma_correct = 1.0;
%%
% fn = 'images/32_input.jpg'; opts.kernel_size = 61; 
% opts.I_reg_wt = 5e-3; opts.gamma_correct = 1.0;
%%-----------------------------------------%%
%%
% fn = 'images/blurry_7.png'; opts.kernel_size = 45; 
% opts.I_reg_wt = 5e-3; opts.gamma_correct = 1.0;
% %%
% fn = 'images/building.jpg'; opts.kernel_size = 31; 
% opts.I_reg_wt = 5e-3; opts.gamma_correct = 1.0;
% %% 
% fn = 'images/real_blur_img3.png'; opts.kernel_size = 45; 
% opts.I_reg_wt = 2e-3; opts.gamma_correct = 1.0;
% %% 
% fn = 'images/desk_cho.png'; opts.kernel_size = 45; 
% opts.I_reg_wt = 5e-3; opts.gamma_correct = 1.0;
% %% 
% fn = 'images/flower.png'; opts.kernel_size = 35; 
% opts.I_reg_wt = 5e-3; opts.gamma_correct = 1.0;
% %% 
% fn = 'images/fountain1_blurry.png'; opts.kernel_size = 45; 
% opts.I_reg_wt = 5e-3; opts.gamma_correct = 1.0;
% %% 
% fn = 'images/IMG_0650_small_patch.png'; opts.kernel_size = 69; 
% opts.I_reg_wt = 5e-3; opts.gamma_correct = 1.0;
% %% 
% fn = 'images/IMG_0656_small.png'; opts.kernel_size = 25; 
% opts.I_reg_wt = 5e-3; opts.gamma_correct = 1.0;
% %% 
% fn = 'images/IMG_0742_small_patch.png'; opts.kernel_size = 45; 
% opts.I_reg_wt = 5e-3; opts.gamma_correct = 1.0;
% %% 
% fn = 'images/las_vegas_2_blur.png'; opts.kernel_size = 39; 
% opts.I_reg_wt = 5e-3; opts.gamma_correct = 1.0;
% %% 
% fn = 'images/las_vegas2_patch_blur_2.png'; opts.kernel_size = 45; 
% opts.I_reg_wt = 5e-3; opts.gamma_correct = 1.0;
% %% 
% fn = 'images/new-image.png'; opts.kernel_size = 31; 
% opts.I_reg_wt = 5e-3; opts.gamma_correct = 1.0;
% %% 
% fn = 'images/test_truth.png'; opts.kernel_size = 35; 
% opts.I_reg_wt = 1e-3; opts.gamma_correct = 1.0;
% %%-----------------------------------------%%
%%
% fn = 'images/las_vegas_blur.png'; opts.kernel_size = 29; 
% opts.I_reg_wt = 5e-3; opts.gamma_correct = 1.0;
blurred = im2double(imread(fn));
[deblurImg, kernel] = blind_deconv_main(blurred, opts);
figure; imshow(deblurImg,[]);
kw = kernel - min(kernel(:));
kw = kw./max(kw(:));
imwrite(kw,['results/' fn(7:end-4) '_kernel.png'])
imwrite(deblurImg,['results/' fn(7:end-4) '_out.png'])
