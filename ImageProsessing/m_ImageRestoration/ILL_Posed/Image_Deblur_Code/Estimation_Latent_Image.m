function S_last = Estimation_Latent_Image(Im, kernel, lambda_pixel, lambda_grad, iter_lambda, opts)
%%
%     The function (9) in our paper.
%%   Parameters: 
%%   Input:
%     @Im: Input blurred image.
%     @kernel: Blur kernel.
%     @lambda_pixel: The weight of L0 regularization on intensity.
%     @lambda_grad: The weight of L0 regularization on gradient.
%     @DisLC: Distribution of the saliency value of blurred image.
%     @opts: Input parameters.
%%   Output:
%     @S_last: Latent image.
%%
%     The Code is created based on the method described in the following paper 
%     [1] Hancheng Yu, Wenkai Wang, and Wenshi Fan
%          An Adaptive Iterative Algorithm for Motion Deblurring based on 
%          Salient Intensity Prior 
%  
%     Author: Hancheng Yu (yuhc@nuaa.edu.cn)
%%
    S = Im;
    fx = [1, -1];
    fy = [1; -1];
    [N,M,D] = size(Im);
    sizeI2D = [N,M];

    otfFx = psf2otf(fx,sizeI2D);
    otfFy = psf2otf(fy,sizeI2D);
    KER = psf2otf(kernel,sizeI2D);
    Den_KER = abs(KER).^2;
    Denormin2 = abs(otfFx).^2 + abs(otfFy ).^2;
    if D>1
        KER = repmat(KER,[1,1,D]);
        Den_KER = repmat(Den_KER,[1,1,D]);
        Denormin2 = repmat(Denormin2,[1,1,D]);
    end
    Normin1 = conj(KER).*fft2(S);

    dx = [-1 1; 0 0];
    dy = [-1 0; 1 0];
    ax = conv2(S, dx, 'valid');
    ay = conv2(S, dy, 'valid');
    mag = (ax.*ax+ay.*ay);
    para_beta = max(mag(:));%parameter of beta
    [DisLC HistLC]= LC(255*S);
    para_alpha = max(DisLC(:));%parameter of alpha
    alpha =lambda_pixel;
    lambda_alpha = 1.1;
    lambda_beta = 2;
    iter_lambda_max = 8;

    while iter_lambda<iter_lambda_max
        beta = lambda_grad/para_beta;
        Denormin = Den_KER + beta*Denormin2+ alpha;
        h = [diff(S,1,2), S(:,1,:) - S(:,end,:)];
        v = [diff(S,1,1); S(1,:,:) - S(end,:,:)];

        if D==1  
            t = (h.^2+v.^2)<para_beta;
        else
            t = sum((h.^2+v.^2),3)<para_beta;
            t = repmat(t,[1,1,D]);
        end
        h(t)=0; v(t)=0;
        clear t;

        if D==1
            [DisLC saliency_min] = LC2(S);
            t = (DisLC.*DisLC)<para_alpha;
        else
            [DisLC saliency_min] = LC2(rgb2gray(S));
            t = (DisLC.*DisLC)<para_alpha;
            t = repmat(t,[1,1,D]);
        end
        DisLC(t) = 0;
        clear t;

        Normin1 = conj(KER).*fft2(Im);
        Normin2 = [h(:,end,:) - h(:, 1,:), -diff(h,1,2)];
        Normin2 = Normin2 + [v(end,:,:) - v(1, :,:); -diff(v,1,1)];
        FS = (Normin1 + beta*fft2(Normin2) + alpha*fft2(DisLC))./Denormin;
        S = real(ifft2(FS));

        para_beta = para_beta/lambda_beta;
        alpha = alpha*lambda_alpha;
        para_alpha = para_alpha/lambda_alpha;
        iter_lambda = iter_lambda*2;
    end
    
    if ( opts.saturation )
        S_last = sign(S).*abs(S).^1.5;
    else
        S_last = S;
    end
end