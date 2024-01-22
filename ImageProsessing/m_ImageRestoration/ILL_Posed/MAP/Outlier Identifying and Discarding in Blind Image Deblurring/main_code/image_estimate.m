function [latent, w_out] = image_coarse(blurred, psf, reg_strength, is_previous)
fftw('planner', 'measure');

% CONSTANTS for sparse priors
w0 = 0.1;
exp_a = 0.8;
thr_e = 0.01;

% CONSTANTS for iterative reweighted least squares
N_iters = 15;
% Finite difference filters
dxf  = [0 -1 1];
dyf  = [0 -1 1]';
dxxf = [-1 2 -1];
dyyf = [-1 2 -1]';
dxyf = [-1 1 0;1 -1 0; 0 0 0];

% boundary handling
%  uses wrap_boundary_liu.. it results in a little bit faster convergence
H = size(blurred,1);    W = size(blurred,2);
w_matrix = zeros(size(blurred),'single');
blurred_w = wrap_boundary_liu(blurred, opt_fft_size([H W]+size(psf)-1));
blurred_w = single(blurred_w);
w_matrix = wrap_boundary_liu(w_matrix, opt_fft_size([H W]+size(psf)-1));
w_matrix(1:H,1:W,:)=1;
% create the initial mask
mask = zeros(size(blurred_w),'single');
mask(1:H, 1:W, :) = 1;
w_matrix((1-mask)==1)=0+eps;
w_matrix(w_matrix>=1) = 1-eps;
w_matrix(w_matrix<=0) = 0+eps;
% run IRLS
latent_w = deconv_L2(blurred_w, blurred_w, psf, w_matrix, reg_strength);
for iter=1:N_iters
    w_matrix = estimate_weightmatrix(blurred_w, latent_w, psf, is_previous);
    ww = w_matrix.*mask;
 
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
    latent_w = deconv_L2(blurred_w, latent_w, psf, ww, reg_strength, weight_x, weight_y, weight_xx, weight_yy, weight_xy);
end

latent = latent_w(1:size(blurred,1), 1:size(blurred,2), :);
w_out = ww(1:size(blurred,1), 1:size(blurred,2), :);

