function [psf,w_out] = psf_fine(blurred, latent, weight, psf, threshold,is_previous)
dx = [-1 1; 0 0];
dy = [-1 0; 1 0];
H = size(blurred,1);    W = size(blurred,2);
blur_B_w = wrap_boundary_liu(blurred, opt_fft_size([H W]+size(psf)-1));
blur_B_tmp = blur_B_w(1:H,1:W,:);
Bx = conv2(blur_B_tmp, dx, 'valid');
By = conv2(blur_B_tmp, dy, 'valid');
[latent_x, latent_y, ~]= threshold_pxpy_v1(latent,max(size(psf)),threshold); 
psf_size = size(psf);

latent_xf = fft2(latent_x);
latent_yf = fft2(latent_y);
    for iter = 1:15
        ww_x = estimate_weightmatrix(Bx, latent_x, psf, is_previous);
        ww_y = estimate_weightmatrix(By, latent_y, psf, is_previous);
                
        b_f = conj(latent_xf)  .* fft2(ww_x.*Bx)+...
                conj(latent_yf) .* fft2(ww_y.*By);
        b = real(otf2psf(b_f, psf_size));
        p.latent_xf = latent_xf;
        p.latent_yf = latent_yf;
        %p.img_size = size(blurred);
        p.img_size = size(Bx);
        p.psf_size = psf_size;
        p.lambda = weight;
        p.ww_x = ww_x;
        p.ww_y = ww_y;
        psf = ones(psf_size) / prod(psf_size);
        psf = conjgrad(psf, b, 21, 1e-5, @compute_Ax, p);
        psf(psf < max(psf(:))*0.05) = 0;
        psf = psf / sum(psf(:));    
    end
    w_out = ww_x;
end

function y = compute_Ax(x, p)
    x_f = psf2otf(x, p.img_size);
    Ixconvk = p.ww_x.*real(ifft2(p.latent_xf.*x_f));
    Iyconvk = p.ww_y.*real(ifft2(p.latent_yf.*x_f));
    y = otf2psf(conj(p.latent_xf).*fft2(Ixconvk) +...
        conj(p.latent_yf).*fft2(Iyconvk), p.psf_size);
    y = y + p.lambda * x;
end
