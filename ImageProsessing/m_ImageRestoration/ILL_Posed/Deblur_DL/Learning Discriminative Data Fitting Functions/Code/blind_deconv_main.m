function [k, lambda_grad, S] = blind_deconv_main(blur_B, k, lambda_grad, weights_filters, parameter_p, filters, opts)
% Do single-scale blind deconvolution using the input initializations
% 
% I and k. The cost function being minimized is: min_{I,k}
%  |B - I*k|^2  + \gamma*|k|_2 + lambda_pixel*|I|_0 + lambda_grad*|\nabla I|_0
%
%% Input:
% @blur_B: input blurred image 
% @k: blur kernel
% @lambda_pixel: the weight for the L0 regularization on intensity
% @lambda_grad: the weight for the L0 regularization on gradient
%
% Ouput:
% @k: estimated blur kernel 
% @S: intermediate latent image
%
% The Code is created based on the method described in the following paper 
%        Jinshan Pan, Zhe Hu, Zhixun Su, and Ming-Hsuan Yang,
%        Deblurring Text Images via L0-Regularized Intensity and Gradient
%        Prior, CVPR, 2014. 

%   Author: Jinshan Pan (sdluran@gmail.com)
%   Date  : 05/18/2014
%=====================================
%% Note: 
% v4.0 add the edge-thresholding 
%=====================================

% % derivative filters
% dx = [-1 1; 0 0];
% dy = [-1 0; 1 0];
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2013-08-11
% H = size(blur_B,1);    W = size(blur_B,2);
% blur_B_w = wrap_boundary_liu(blur_B, opt_fft_size([H W]+size(k)-1));
% blur_B_tmp = blur_B_w(1:H,1:W,:);
% Bx = conv2(blur_B_tmp, dx, 'valid');
% By = conv2(blur_B_tmp, dy, 'valid');
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% filters
% filters{1} = [1, -1];
% filters{2} = [1; -1];
% filters{3} = [-1; 2; -1];
% filters{4} = [-1, 2, -1];
% filters{5} = [-1 1;1 -1];
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
%% Weight for kernel esitmation
gamma_kernel = 2;
 g_residual = cell(length(filters) + 1, 1);
for ii =1:length(filters) + 1
    g_residual{ii} = zeros(size(blur_B));
end
for iter = 1:opts.xk_iter
    %S = L0Restoration_lp_v3(blur_B, k, lambda_grad, g_residual, weights_filters, filters, 2);
    %%S = L0Restoration_lp_v3_grad_pixel(blur_B, k, lambda_grad, g_residual, weights_filters, filters, 2);
    S = L0Restoration_pixel_gradient_lp_v1(blur_B, k, lambda_grad, lambda_grad, g_residual, weights_filters, filters, 2);
    k_prev = k;
    %% using FFT method for estimating kernel
    k = estimate_psf(blur_B, S, gamma_kernel, g_residual, weights_filters, filters, size(k_prev));
    %%
    fprintf('pruning isolated noise in kernel...\n');
    CC = bwconncomp(k,8);
    for ii=1:CC.NumObjects
        currsum=sum(k(CC.PixelIdxList{ii}));
        if currsum<.1
            k(CC.PixelIdxList{ii}) = 0;
        end
    end
    k(k<0) = 0;
    k=k/sum(k(:));
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Parameter updating
    %lambda_pixel = lambda_pixel/1.1;  %% for natural images
    if lambda_grad~=0;
        lambda_grad = max(lambda_grad/1.1, 1e-4);
        %lambda_grad = lambda_grad;
    else
        lambda_grad = 0;
    end
    %
    figure(1);
    S(S<0) = 0;
    S(S>1) = 1;
    subplot(1,3,1); imshow(blur_B,[]); title('Blurred image');
    subplot(1,3,2); imshow(S,[]);title('Interim latent image');
    subplot(1,3,3); imshow(k,[]);title('Estimated kernel');
    %         imwrite(S,'tmp.png')
    %   kw = k - min(k(:));
    %   kw = kw./max(kw(:));
    %   imwrite(kw,'tmp_kernel.png')
%       mat_outname=sprintf('intermediate_kernels/interim_kernel_%d.mat',iter);
%       save(mat_outname,'k');
end;
k(k<0) = 0;
k = k ./ sum(k(:));
