function psf = estimate_psf(blurred, latent, weight, g_residual, filters_weights, filters, psf_size)
 
%     latent_xf = fft2(latent_x);
%     latent_yf = fft2(latent_y);
%     blurred_xf = fft2(blurred_x);
%     blurred_yf = fft2(blurred_y);
%     % compute b = sum_i w_i latent_i * blurred_i
%     b_f = conj(latent_xf)  .* blurred_xf ...
%         + conj(latent_yf)  .* blurred_yf;
%     b = real(otf2psf(b_f, psf_size));
% 
%     p.m = conj(latent_xf)  .* latent_xf ...
%         + conj(latent_yf)  .* latent_yf;
    blurred_f = fft2(blurred);
    latent_f = fft2(latent);
    blurred_list = cell(length(filters),1);
    latent_list = cell(length(filters),1);
    for ii = 1:length(filters)
        %otf_filters{ii} = psf2otf(filters{ii}, p.img_size);
        blurred_list{ii} = imfilter(blurred, filters{ii}, 'same', 'replicate'); 
        latent_list{ii} = imfilter(latent, filters{ii}, 'same', 'replicate'); 
    end
    g_residual_fft = cell(length(filters) + 1,1);
    g_residual_fft{1} = fft2(g_residual{1});
    blurred_list_fft = cell(length(filters),1);
    latent_list_fft = cell(length(filters),1);
    otf_filters = cell(length(filters),1);
    p.img_size = size(blurred);
    for ii = 1:length(filters)
        %otf_filters{ii} = psf2otf(filters{ii}, p.img_size);
        blurred_list_fft{ii} = fft2(blurred_list{ii});
        latent_list_fft{ii} = fft2(latent_list{ii});
        g_residual_fft{ii + 1} = fft2(g_residual{ii + 1});
    end
    % compute b = sum_i w_i latent_i * blurred_i
    %filters_weights(1) = 0;
    b_f = filters_weights(1)* conj(latent_f).* blurred_f + filters_weights(1)* conj(latent_f).* g_residual_fft{1};
    for ii = 1:length(filters)
        b_f = b_f + filters_weights(ii + 1)*(conj(latent_list_fft{ii}).* blurred_list_fft{ii})...
            + filters_weights(ii + 1)* conj(latent_f).* g_residual_fft{ii+1};
    end
    b = real(otf2psf(b_f, psf_size));
    %%
    p.m = filters_weights(1)* conj(latent_f).* latent_f;
    for ii = 1:length(filters)
        p.m = p.m + filters_weights(ii + 1)*(conj(latent_list_fft{ii}).* latent_list_fft{ii});
    end
    
    p.psf_size = psf_size;
    p.lambda = weight;

    psf = ones(psf_size) / prod(psf_size);
    psf = conjgrad(psf, b, 20, 1e-5, @compute_Ax, p);
    
    psf(psf < max(psf(:))*0.05) = 0;
    psf = psf / sum(psf(:));    
end

function y = compute_Ax(x, p)
    x_f = psf2otf(x, p.img_size);
    y = real(otf2psf(p.m .* x_f, p.psf_size));
    y = y + p.lambda * x;
end
