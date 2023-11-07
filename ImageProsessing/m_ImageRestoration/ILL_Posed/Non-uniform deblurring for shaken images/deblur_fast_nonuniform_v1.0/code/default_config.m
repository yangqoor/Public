% Author:     Oliver Whyte <oliver.whyte@ens.fr>
% Date:       January 2012
% Copyright:  2012, Oliver Whyte
% Reference:  O. Whyte, J. Sivic, A. Zisserman, and J. Ponce. "Non-uniform Deblurring for Shaken Images". IJCV, 2011 (accepted).
%             O. Whyte, J. Sivic and A. Zisserman. "Deblurring Shaken and Partially Saturated Images". In Proc. CPCV Workshop at ICCV, 2011.
% URL:        http://www.di.ens.fr/willow/research/deblurring/, http://www.di.ens.fr/willow/research/saturation/

% Max dimension at finest scale
max_dim = 1024;

% Root directory to store results
results_root = pwd;

% Default config_name is image file name
[pathstr, config_name, ext] = fileparts(file_shake);
clear pathstr ext

% New imresize function causes trouble, this should ultimately be changed
if exist('imresize_old') == 2
	imresizefn = @imresize_old;
else
	imresizefn = @imresize;
end

% Visual feedback of algorithm running
do_display = false;

% Save out images of all the intermediate results?
%   0 = no, 1 = save deblurred result at each level, 2 = save all intermediate images
save_intermediate_images  = 0;
% Save pyramids and parameters for entire process into a .mat file?
save_mat = true;
% Save pyramids after each scale?
save_intermediate_pyramids = false;

% Is image raw (linear) or jpg (with gamma curve applied)
if ~exist('israw','var')
    israw = false;
end

% Parameters of bilateral filter
bi_sigma_spatial0    = 2;
bi_sigma_spatial0    = bi_sigma_spatial0/sqrt(2); % reducing bi_sigma_spatial by factor of sqrt(2), due to change in jcbfilter
bi_sigma_range0      = 0.5; % should be set relative to range of values in image (especially if using raw images whose range is 256 times larger)
bi_size              = 5;

% Parameters of shock filter
shock_dt0            = 1;
shock_iters          = 1;

% Decrease parameters over iterations as suggested by Cho & Lee
param_decrease = 0.9;

% Parameters of gradient histogramming
grad_dir_bins = 4;
grad_dir_quant = pi/grad_dir_bins;
grad_thresh_decrease = 0.9; % decrease threshold on gradient magnitudes at each iteration (Cho & Lee: 0.9)
r = 2; % factor to multiply necessary number of retained gradients by (Cho & Lee: 2)

% Spatial binning when histogramming gradients
if non_uniform
    num_vert_regions = 3;
    num_horz_regions = 3;
else
    num_vert_regions = 1;
    num_horz_regions = 1;
end

% Weights for gradient data terms from Shan et al. 2008
omega0 = 1;   % weight for image pixel values. omega = 1 / 2^q, where q is order of operator
omega1 = 1/2; % weight for 1st order image derivatives
omega2 = 1/4; % weight for 2nd order image derivatives

% Regularization weights for non-blind image estimation step
alpha = 0.0005; % latent image regularization weight (Cho & Lee: 0.1)
kf_lambda = 8e3; % Krishnan & Fergus lambda parameter
kf_exponent = 0.5; % Krishnan & Fergus sparse gradient exponent

% Threshold kernel elements at 1/kernel_threshold of the max value (Cho & Lee: 20)
kernel_threshold = 20;

% Regularization weight for kernel estimation step
beta = 5; % kernel regularization weight (Cho & Lee: 5)
num_cg_iters = 5; % number of conjugate gradient iterations in kernel estimation

% Parameters relating to camera rotations
theta_pre = [0;0;0]; % Kernel pre-rotation to apply
pixels_per_theta_step = 1; % Kernel sampling resolution
% parameters for dimensions of non-uniform kernel
blur_x_lims = floor(((BLUR_KERNEL_SIZE)-1)/2)*[-1 1];
blur_y_lims = floor(((BLUR_KERNEL_SIZE)-1)/2)*[-1 1];
if non_uniform
	blur_z_lims = floor(((BLUR_KERNEL_SIZE)-1)/2)*[-1 1];
else
	blur_z_lims = [0 0];
end

% Multiscale parameters
scale_ratio_i = 1/sqrt(2); % scale ratio for image
scale_ratio_k = 1/sqrt(2); % scale ratio for kernel (must equal scale_ratio_i for uniform blur)
max_levels = 9;

% Number of iterations at each scale (Cho & Lee: 7)
for s = 1:max_levels, num_iters(s) = 5; end

% Recenter kernel after each iteration
recenter_kernel = 1;

% Dilate current active region of kernel when solving at next scale
kernel_dilate_radius = 1;

% Saturation threshold
sat_thresh = 235.5/256;

% Default methods for kernel estimation and image estimation
kernel_method = 'lars';
image_method = 'conjgrad';

% Do kernel estimation? (if not kernel will need to be loaded)
do_estimate_kernel = 1;
% Do image estimation?
do_deblur = ones(max_levels,1); % estimate image at all levels
% Perform colour deblurring at each level?
do_colour = zeros(max_levels,1);    do_colour(1) = 1; % last level only

% What to estimate the kernel from? 'blind', or 'true' if true sharp image available
estimate_kernel_from = 'blind';

% Number of iterations in iterative non-blind deblurring algorithms
deconv_maxit = 20;

% Do the kernel thresholding step suggested by Cho & Lee?
threshold_kernel = true; % LEAVE THIS ON!!

% Number of threads to use for multi-threaded computation of BtB
setenv('OMP_NUM_THREADS','2');

% Variables which allow overriding focal length from EXIF tags
focal_length_in_35mm_true = [];
focal_length_in_35mm_shake = [];

% Which levels of the pyramid to start and end on?
first_level = -1; % -1 means start at the highest level
final_level = 1;

% What method to use to compute BtB?
BtB_method = 'exact'; % 'exact' or 'eff'

% Max number of non zeros in kernel for lars-lasso
% Can be important to avoid using too much memory
max_nonzeros_w = 200;

update_saturation_mask = 0;

% Convenience flag to enable / disable fast approximation in both kernel and image estimation steps
fast_approx = 1;

% Default filenames for storing results
filename_kernel = @(scale,iter,note) sprintf('s%02d_it%04d_%s.png',scale,iter,note);
filename_image  = @(im,scale,iter,note) sprintf('s%02d_it%04d_%s.jpg',scale,iter,note);

