function [k, S,opts] = Deblur_One_Scale(blur_B, k, lambda_pixel,lambda_grad, threshold, opts)
%%
%%   Parameters: 
%%   Input:
%     @blur_B: Input blurred image.
%     @k: Blur kernel.
%     @lambda_pixel: The weight of L0 regularization on intensity.
%     @lambda_grad: The weight of L0 regularization on gradient.
%     @opts: Input parameters.
%%   Output:
%     @k: Estimated blur kernel 
%     @S: Intermediate latent image
%     @opts: Input parameters.
%%
%     The Code is created based on the method described in the following paper 
%     [1] Hancheng Yu, Wenkai Wang, and Wenshi Fan
%          An Adaptive Iterative Algorithm for Motion Deblurring based on 
%          Salient Intensity Prior 
%  
%     Author: Hancheng Yu (yuhc@nuaa.edu.cn)
%%
    dx = [-1 1; 0 0];
    dy = [-1 0; 1 0];
    H = size(blur_B,1);
    W = size(blur_B,2);

    blur_B_w = wrap_boundary_liu(blur_B, opt_fft_size([H W]+size(k)-1));
    blur_B_tmp = blur_B_w(1:H,1:W,:);

    Bx = conv2(blur_B_tmp, dx, 'valid');
    By = conv2(blur_B_tmp, dy, 'valid');
    [m1 n1] = size(k);
    Ceps_pre = Error_Ceps(Bx,By,m1,n1);

    iter = 1;
    Error_C_pre = 0;
    iter_lambda = opts.iter_lambda;
    while iter <= opts.xk_iter
        S = Estimation_Latent_Image(blur_B_w, k, lambda_pixel, lambda_grad, iter_lambda, opts);
        S = S(1:H,1:W,:);
        [latent_x, latent_y, threshold]= threshold_pxpy_v1(S,max(size(k)),threshold); 
        
        Ceps = Error_Ceps(latent_x, latent_y,m1,n1);
        Error_C = mean2(abs(Ceps_pre - Ceps));
        if ( ( Error_C > (Error_C_pre*(1 - opts.ks))))
            k_prev = k;
            k = estimate_psf(Bx, By, latent_x, latent_y, 2, size(k_prev));
            fprintf('pruning isolated noise in kernel...\n');

            CC = bwconncomp(k,8);
            for ii=1:CC.NumObjects
                currsum=sum(k(CC.PixelIdxList{ii}));
                if currsum < min(0.1,opts.ks)
                    k(CC.PixelIdxList{ii}) = 0;
                end
            end

            k(k<0) = 0;
            k=k/sum(k(:));
            S(S<0) = 0;
            S(S>1) = 1;
            figure(1); 
            subplot(1,3,1); imshow(blur_B,[]); title('Blurred image');
            subplot(1,3,2); imshow(S,[]);title('Interim latent image');
            subplot(1,3,3); imshow(k,[]);title('Estimated kernel');
            
            lambda_pixel = lambda_pixel/1.1;
            lambda_grad = lambda_grad/1.1;
                
            if ( iter > 1 )
                Error_k = mean2(abs(k-k_pre));
                if ( Error_k < 2e-5)
                    break;
                end
            end
        else
            break;
        end
        
        Error_C_pre = Error_C;
        k_pre = k;
        S_pre = S;
        iter_lambda = max(iter_lambda, 5e-4);
        iter = iter+1;
    end
end