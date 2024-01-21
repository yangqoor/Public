function psf = estimate_psf2(blurred_y, latent_x, weight, psf_size)

    %----------------------------------------------------------------------
    % these values can be pre-computed at the beginning of each level
%     blurred_f = fft2(blurred);
%     dx_f = psf2otf([1 -1 0], size(blurred));
%     dy_f = psf2otf([1;-1;0], size(blurred));
%     blurred_xf = dx_f .* blurred_f; %% FFT (Bx)
%     blurred_yf = dy_f .* blurred_f; %% FFT (By)
    %latent_x = latent_x(1+(psf_size(1)-1)/2:end-(psf_size(1)-1)/2,1+(psf_size(2)-1)/2:end-(psf_size(2)-1)/2);
   
    for i =1:8
    latent_x1(:,:,i)=latent_x(1+(psf_size(1)-1)/2:end-(psf_size(1)-1)/2,1+(psf_size(2)-1)/2:end-(psf_size(2)-1)/2,i);    
    latent_xf(:,:,i) = fft2(latent_x1(:,:,i));
    blurred_yf(:,:,i) = fft2(blurred_y(:,:,i));
    end
    % compute b = sum_i w_i latent_i * blurred_i
    b_f=0;
    for i =1:8
    b_f = b_f+conj(latent_xf(:,:,i)).* blurred_yf(:,:,i);
    end
    b = real(otf2psf(b_f, psf_size));
     
    p.m=0;
    for i=1:8
    p.m = p.m+conj(latent_xf(:,:,i))  .* latent_xf(:,:,i);
    end
    
    
    %p.img_size = size(blurred);
    blurredsize = latent_xf(:,:,i);
    p.img_size = size(blurredsize);
    p.psf_size = psf_size;
    p.lambda = weight;

    psf = ones(psf_size) / prod(psf_size);
    psf = conjgrad(psf, b, 20, 1e-5, @compute_Ax, p);
    
   % psf(psf < max(psf(:))*0.00) = 0;   
   % psf(psf < 0) = 0;

    %psf = psf / sum(psf(:));   
     psf(psf < max(psf(:))*0.0) = 0;  
     psf = psf / sum(psf(:));   
end

function y = compute_Ax(x, p)
    x_f = psf2otf(x, p.img_size);
    y = otf2psf(p.m .* x_f, p.psf_size);
    y = y + p.lambda * x;
end
