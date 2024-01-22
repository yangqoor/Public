clear all;

% Required parameters for this image =========================================
% Filename of image to deblur
file_shake = 'garden.jpg';
% Size of blur kernel in the image
BLUR_KERNEL_SIZE = 150;
% Override output name
% config_name = 'garden';
% Spatially-variant blur?
non_uniform = 1;
% ============================================================================

% Load default settings ======================================================
default_config;
% ============================================================================

% Optional overrides of parameters for this image ============================
max_dim = 1024; % resize image at start to be no larger than this
beta = 0.01;    % kernel regularisation
alpha = 0.005;  % image regularisation
focal_length_in_35mm_shake = 40; % focal length if cannot be read from EXIF tags

% Convenience flag to enable / disable fast approximation in both kernel and image estimation steps.
% fast_approx = 0;

% Don't always need to start at the top of the pyramid, often it's a waste of time
% first_level = 7;

% Give visual feedback of the current estimates of the image and kernel?
% do_display = 1;

% In the final iteration, use the following additional non-blind deblurring algorithms
% Use a cell array for multiple methods: {'krishnan', 'rl'}
image_method_final = 'combinedrl_eff';
deconv_maxit_final = 50;

% Save out images of all the intermediate results?
%   0 = no, 1 = save deblurred result at each level, 2 = save all intermediate images
save_intermediate_images  = 1;
% ============================================================================

% Optional -- instead of printing output to Matlab prompt, write it to file
% logfile = fopen('deblurlog.txt','w');

% Now run the algorithm ======================================================
blind_deblur_map;
% ============================================================================

% fclose(logfile)
