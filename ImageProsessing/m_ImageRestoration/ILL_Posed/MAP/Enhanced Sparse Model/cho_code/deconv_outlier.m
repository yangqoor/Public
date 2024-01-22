function [latent, mask] = deconv_outlier(blurred, psf, sigma, reg_strength)
% deconv_outlier.m
%
%   Deconvolution with outlier handling
%
%     written by Sunghyun Cho (sodomau@postech.ac.kr)
%
%   Please refer to the reference below:
%     - Sunghyun Cho, Jue Wang, Seungyong Lee, "Handling Outliers in
%     Non-blind Image Deconvolution," ICCV 2011
%   
%   All rights are reserved.
%   If you use this code for making images for your paper, please cite the
%   paper above.
%   Thank you!
%
%   INPUT:
%     - blurred - blurred image (single or double, 1 or 3 channels,
%                                intensity values: 0~1)
%     - psf - point spread function
%     - sigma - standard deviation for inlier noise (gaussian distribution)
%               We found that 5/255 works well for most cases
%     - reg_strength - regularization strength for sparse priors
%               We used 0.003, 0.005, or 0.01
%
%   OUTPUT:
%     - latent - deblurred image
%     - mask - detected inlier map
%
fftw('planner', 'measure');

% CONSTANTS for sparse priors
w0 = 0.1;
exp_a = 0.8;
thr_e = 0.01;

% CONSTANTS for iterative reweighted least squares
N_iters = 15;

% CONSTANTS for noise distributions
p_outlier = 0.1;        % p(m_x=0) := 0.1
p_b_given_outlier = 1;  % uniform distribution for p(b|m_x=0)
p_b_outlier = p_b_given_outlier .* p_outlier;

% Finite difference filters
dxf  = [0 -1 1];
dyf  = [0 -1 1]';
dxxf = [-1 2 -1];
dyyf = [-1 2 -1]';
dxyf = [-1 1 0;1 -1 0; 0 0 0];

% boundary handling
%  uses wrap_boundary_liu.. it results in a little bit faster convergence
H = size(blurred,1);    W = size(blurred,2);
blurred_w = wrap_boundary_liu(blurred, opt_fft_size([H W]+size(psf)-1));
blurred_w = single(blurred_w);

% create the initial mask
mask = zeros(size(blurred_w), 'single');
mask(1:H, 1:W, :) = 1;

% run IRLS
latent_w = deconv_L2(blurred_w, blurred_w, psf, mask, reg_strength);

for iter=1:N_iters
%     fprintf('iter: %d\n', iter);
    
    % find outliers
    bb = fftconv(latent_w, psf);
    diff = bb - blurred_w;
    p_b_given_inlier = 1/sqrt(2*pi*sigma^2)*exp(-diff.^2/(2*sigma^2));
    p_b_inlier = p_b_given_inlier .* (1-p_outlier);
    s = p_b_inlier ./ (p_b_inlier + p_b_outlier);
    ww = mask .* s;
    
    % find clipped pixels
    ww(bb>1) = 0;
    ww(bb<0) = 0;
 
    
    % compute weights for sparse priors
    dx  = imfilter(latent_w,dxf,'same','circular');
    dy  = imfilter(latent_w,dyf,'same','circular');
    dxx = imfilter(latent_w,dxxf,'same','circular');
    dyy = imfilter(latent_w,dyyf,'same','circular');
    dxy = imfilter(latent_w,dxyf,'same','circular');
  
    weight_x  = w0*max(abs(dx),thr_e).^(exp_a-2);
    weight_y  = w0*max(abs(dy),thr_e).^(exp_a-2);
    weight_xx = 0.25*w0*max(abs(dxx),thr_e).^(exp_a-2); 
    weight_yy = 0.25*w0*max(abs(dyy),thr_e).^(exp_a-2);
    weight_xy = 0.25*w0*max(abs(dxy),thr_e).^(exp_a-2);

    % run deconvolution
    latent_w = deconv_L2(blurred_w, latent_w, psf, mask, reg_strength, weight_x, weight_y, weight_xx, weight_yy, weight_xy);
end

latent = latent_w(1:size(blurred,1), 1:size(blurred,2), :);

if nargout == 2
    mask = s;
end
