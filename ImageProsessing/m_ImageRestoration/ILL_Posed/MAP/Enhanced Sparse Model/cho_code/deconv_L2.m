function latent = deconv_L2(blurred, latent0, psf, data_we, L2_we, ...
                                          weight_x, weight_y, weight_xx, weight_yy, weight_xy)
% deconv_L2.m
%
%   Deconvolution using a Gaussian prior
%
%     written by Sunghyun Cho (sodomau@postech.ac.kr)
%                                      
    if ~exist('weight_x', 'var')
        weight_x = ones(size(blurred), 'single');
        weight_y = ones(size(blurred), 'single');
        weight_xx = zeros(size(blurred), 'single');
        weight_yy = zeros(size(blurred), 'single');
        weight_xy = zeros(size(blurred), 'single');
    end
    
    img_size = size(blurred);

    dxf=[0 -1 1];
    dyf=[0 -1 1]';
    dyyf=[-1; 2; -1];
    dxxf=[-1, 2, -1];
    dxyf=[-1 1 0;1 -1 0; 0 0 0];
    
    latent = latent0;

    psf_f = single(psf2otf(psf, img_size));

    % compute b
    b = real(ifft2(fft2(data_we.*blurred) .* conj(psf_f)));
    b = b(:);

    % set x
    x = latent(:);

    % run conjugate gradient
    cg_param.psf = psf;
    cg_param.L2_we = L2_we;
    cg_param.data_we = data_we;
    cg_param.img_size = img_size;
    cg_param.psf_f = psf_f;
    cg_param.weight_x = weight_x;
    cg_param.weight_y = weight_y;
    cg_param.weight_xx = weight_xx;
    cg_param.weight_yy = weight_yy;
    cg_param.weight_xy = weight_xy;
    cg_param.dxf = dxf;
    cg_param.dyf = dyf;
    cg_param.dxxf = dxxf;
    cg_param.dyyf = dyyf;
    cg_param.dxyf = dxyf;
    x = conjgrad(x, b, 25, 1e-4, @Ax, cg_param); %, @vis);
    
    latent = reshape(x, img_size);
end

function y = Ax(x, p)
    x = reshape(x, p.img_size);
    x_f = fft2(x);
    y = real(ifft2(fft2(p.data_we.*real(ifft2(p.psf_f.*x_f))).*conj(p.psf_f)));
    y = y + p.L2_we*imfilter(p.weight_x.*imfilter(x, p.dxf, 'circular'), p.dxf, 'conv', 'circular');
    y = y + p.L2_we*imfilter(p.weight_y.*imfilter(x, p.dyf, 'circular'), p.dyf, 'conv', 'circular');
    y = y + p.L2_we*imfilter(p.weight_xx.*imfilter(x, p.dxxf, 'circular'), p.dxxf, 'conv', 'circular');
    y = y + p.L2_we*imfilter(p.weight_yy.*imfilter(x, p.dyyf, 'circular'), p.dyyf, 'conv', 'circular');
    y = y + p.L2_we*imfilter(p.weight_xy.*imfilter(x, p.dxyf, 'circular'), p.dxyf, 'conv', 'circular');
    y = y(:);
end

function vis(x, iter, p)
    if mod(iter,5) == 0
        x = reshape(x, p.img_size);
        x = x(1:end-(size(p.psf,1)-1), 1:end-(size(p.psf,2)-1), :);
        figure(1), imshow(x), title(sprintf('%d',iter));
        drawnow;
    end
end
