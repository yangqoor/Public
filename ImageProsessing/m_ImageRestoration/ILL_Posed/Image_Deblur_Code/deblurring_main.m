function [kernel, interim_latent] = deblurring_main(y, opts, Kernel,kurt )
%%
%%   Parameters: 
%%   Input:
%     @y: Blurred image (grayscale).
%     @opts: Input parameters.
%     @Kernel: Estimated blur kernel.
%     @kurt: Kurtosis of input blurred image.
%%   Output:
%     @kernel: Estimated blur kernel.
%     @interim_latent: Intermediate latent image.
%%
%     The Code is created based on the method described in the following paper 
%     [1] Hancheng Yu, Wenkai Wang, and Wenshi Fan
%          An Adaptive Iterative Algorithm for Motion Deblurring based on 
%          Salient Intensity Prior 
%  
%     Author: Hancheng Yu (yuhc@nuaa.edu.cn)
%%
    ret = sqrt(0.5);
    [opts.kernel_size,opts.kernel_size2] = size(Kernel);
    if (opts.kernel_size > opts.kernel_size2)
        maxitr= max(floor(log(5/min(opts.kernel_size))/log(ret)),0);
    else
        maxitr= max(floor(log(5/min(opts.kernel_size2))/log(ret)),0);
    end
    num_scales = maxitr + 1;
    fprintf('Max iteration level:%d\n', num_scales);

    retv=ret.^[0:maxitr];
    k1list=ceil(opts.kernel_size*retv);
    k1list=k1list+(mod(k1list,2)==0);
    k2list=ceil(opts.kernel_size2*retv);
    k2list=k2list+(mod(k2list,2)==0);
    k1list = max(k1list,3);
    k2list = max(k2list,3);

    dx = [-1 1; 0 0];
    dy = [-1 0; 1 0];
    lambda_pixel = 5e-3*kurt*kurt;
    lambda_grad = 25e-2/(kurt*kurt);
    
    for s = num_scales:-1:1
        opts.ks = max(opts.ks-0.02,0.01);
        if (s == num_scales)
            ks = imresize(Kernel, k1list(s)/k1list(1));
            ks(ks<max(ks(:))*0.05) = 0;
            ks = ks.^0.5;
            ks = ks / sum(ks(:));   
            k1 = k1list(s);
            k2 = k2list(s);
        else
            k1 = k1list(s);
            k2 = k2list(s); 
            ks = resizePSF(ks,1/ret,k1list(s),k2list(s));
        end

        cret=retv(s);
        ys=downSmpImC(y,cret);
        
        fprintf('Processing scale %d/%d; kernel size %dx%d; image size %dx%d\n',s, num_scales, k1, k2, size(ys,1), size(ys,2));
        [~, ~, threshold]= threshold_pxpy_v1(ys,max(size(ks)));
        [ks,interim_latent,opts] = Deblur_One_Scale(ys, ks,lambda_pixel, lambda_grad,threshold, opts);

        lambda_pixel = lambda_pixel/2;
        lambda_grad = lambda_grad/2;
        opts.iter_lambda = opts.iter_lambda/2;
        lambda_grad = max(lambda_grad,opts.lambda_grad_min);
        
        ks = adjust_psf_center(ks);
        ks(ks(:)<0) = 0;
        sumk = sum(ks(:));
        ks = ks./sumk;

        if (s == 1)
            kernel = ks;
            if opts.k_thresh > 0 
                kernel(kernel(:) < max(kernel(:))/opts.k_thresh) = 0;
            else
                kernel(kernel(:) < 0) = 0;
            end
            kernel = kernel / sum(kernel(:));
        end
    end
end
