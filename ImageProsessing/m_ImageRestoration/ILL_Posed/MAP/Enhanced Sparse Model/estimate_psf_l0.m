function psf = estimate_psf_l0(blurred_x, blurred_y, latent_x, latent_y, weight,tau, k_prev,theta)
% Please cite the paper if the code is useful.
% @inproceedings{DBLP:conf/eccv/ChenFLLZ20,
%   author    = {Liang Chen and
%                Faming Fang and
%                Shen Lei and
%                Fang Li and
%                Guixu Zhang},
%   title     = {Enhanced Sparse Model for Blind Deblurring},
%   booktitle = {{ECCV}},
%   year      = {2020}
% }    

    latent_xf = fft2(latent_x);
    latent_yf = fft2(latent_y);
    blurred_xf = fft2(blurred_x);
    blurred_yf = fft2(blurred_y);
    psf_size = size(k_prev);
    tau1 = 2*tau;
    psf = k_prev;
    iter_max = 5;
    %% 5 is not the necessary iteration step, 
    %% you can replace it with smaller figure for faster processing time.
    for iter = 1:iter_max
        g_h = blurred_x - fftconv(latent_x,psf);
        g_h = sign(g_h).*max(abs(g_h)-tau*theta/(2*tau1),0);
        g_v = blurred_y - fftconv(latent_y,psf);
        g_v = sign(g_v).*max(abs(g_v)-tau*theta/(2*tau1),0);
        t_h = g_h.^2<tau/tau1; t_v = g_v.^2<tau/tau1;
        g_h(t_h)=0; g_v(t_v) = 0;
        temp = conj(latent_xf).*fft2(blurred_x - g_h) ...
             + conj(latent_yf).*fft2(blurred_y - g_v);
        b_f = tau1*temp + conj(latent_xf)  .* blurred_xf ...
            + conj(latent_yf)  .* blurred_yf;
        b = real(otf2psf(b_f, psf_size));

        p.m = conj(latent_xf)  .* latent_xf ...
            + conj(latent_yf)  .* latent_yf;
        p.m = p.m*(1+tau1);
        p.img_size = size(blurred_xf);
        p.psf_size = psf_size;
        p.lambda = weight;
        psf = conjgrad(psf, b, 8, 1e-5, @compute_Ax, p);
        tau1 = tau1*2;
    end
    psf(psf < max(psf(:))*0.05) = 0;
    psf = psf / sum(psf(:));
end

function y = compute_Ax(x, p)
    x_f = psf2otf(x, p.img_size);
    y = otf2psf(p.m .* x_f, p.psf_size);
    y = y + p.lambda * x;
end
