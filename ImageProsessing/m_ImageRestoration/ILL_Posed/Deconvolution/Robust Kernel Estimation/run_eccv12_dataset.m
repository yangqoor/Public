clc;
clear;
close all;
%% ==Required input parameters for each example== %%
% The regularization weight in final non-blind deconvolution(\lambda in (16))
% typically set as 1e-3,2e-3, 3e-3, 4e-3, 5e-3, or 6e-3;
opts.I_reg_wt = 5e-3;
% gamma correction: typically  set as 1.0
opts.gamma_correct = 1.0;
% maximum number of I/k alternations at each level (4 by defalut); 
opts.Ik_iter = 4;
%% ================================== %%
opts.I_reg_wt = 3e-3; opts.gamma_correct = 1.0;
% display the intermdiate results at each iteration (1/0)
opts.display = 0;
dirname = 'eccv12_dataset/results';
k_size = [41, 41, 31, 41, 41, 41, 41, 145, 145, 145, 79, 41];
for i=1:4
    for j=1:12
        [i,j]
        img_outname=sprintf('%s/Blurry%d_%d_out.png',dirname,i,j);
        ker_outname=sprintf('%s/Blurry%d_%d_out_kernel.png',dirname,i,j);
        filename = sprintf('eccv12_dataset/Blurry%d_%d.png',i,j);
        opts.kernel_size = k_size(j);    
        blurred = im2double(imread(filename));
        [deblurImg, kernel] = blind_deconv_main(blurred, opts);
        k = kernel - min(kernel(:));
        k = k./max(k(:));
        imwrite(k,ker_outname);
        imwrite(deblurImg,img_outname);
    end
end
%%
%%

