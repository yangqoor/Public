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
opts.I_reg_wt = 5e-3; opts.gamma_correct = 1.0;
% display the intermdiate results at each iteration (1/0)
opts.display = 0;
dirname = 'low-illumination_images/results';
ssde_our = zeros(4,8);
k_size = [19, 17, 15, 27, 13, 21, 23, 23];
for i=1:10
    for j=1:8
        [i,j]
        img_outname=sprintf('%s/saturated_img%d_%d_out.png',dirname,i,j);
        ker_outname=sprintf('%s/saturated_img%d_%d_kernel.png',dirname,i,j);
        y = imread(sprintf('low-illumination_images/saturated_img%d_%d_blur.png',i,j));
        y = im2double(y);
        if size(y,3)==3
            yg = rgb2gray(y);
        else
            yg = y;
        end
        opts.kernel_size = k_size(j);
        [deblur, kernel] = blind_deconv_main(y, opts);
        k = kernel - min(kernel(:));
        k = k./max(k(:));
        imwrite(k,ker_outname)
        imwrite(deblur,img_outname)
    end
end

