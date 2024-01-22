function deblur_web(file_shake,params)
% Set Matlab and OMP thread limits
setenv('OMP_NUM_THREADS','1');
% Required parameters for this image =========================================
% file_shake: filename of image to deblur
% BLUR_KERNEL_SIZE: size of blur kernel in the image
if isfield(params,'output_directory')
    output_directory = params.output_directory;
else
    [output_directory, fname, ext] = fileparts(file_shake);
end
% spatially-variant blur?
non_uniform = 1;
if isfield(params,'blurmodel'),    non_uniform = params.blurmodel; end
BLUR_KERNEL_SIZE = params.blursize;
% ============================================================================

% Load default settings ======================================================
default_config;
% ============================================================================

save_mat = false; % don't save .mat files
% filename_kernel = @(scale,iter,note) sprintf('%d-%s.png',scale,note);
% filename_image  = @(im,scale,iter,note) sprintf('%d-%s-%dpx.jpg',scale,note,max(size(im)));
filename_kernel = @(scale,iter,note) fullfile('intermediate',sprintf('%d-%s.png',scale,note));
filename_image  = @(im,scale,iter,note) fullfile('intermediate',sprintf('%d-%s-%dpx.jpg',scale,note,max(size(im))));
filename_intermediate_kernel  = 'psf-in-progress.png';
filename_intermediate_image  = 'deblurred-in-progress.jpg';
filename_final_kernel  = 'psf-final.png';
filename_final_image  = 'deblurred-final.jpg';
if ~exist(output_directory,'dir'), mkdir(output_directory); end
if ~exist(fullfile(output_directory,'intermediate'),'dir'), mkdir(output_directory,'intermediate'); end

% Optional overrides of default parameters for this image ====================
beta = 0.01;
alpha = 0.005;
max_dim = 1024;
if isfield(params,'beta'),      beta  = params.beta;    end
if isfield(params,'alpha'),     alpha = params.alpha;   end
if isfield(params,'maxsize'),   max_dim = min(params.maxsize,1024);   end

if isfield(params,'logfile'),   logfile  = fopen(params.logfile,'w');    end

% Disable fast approximation
% fast_approx = 0;

% Don't always need to start at the top of the pyramid, often it's a waste of time
% first_level = 6;

% Give visual feedback of the current estimates of the image and kernel?
% do_display = 1;

% In the final iteration, use the following deblurring algorithms
if isfield(params,'nonblind'),    image_method_final = params.nonblind; end
% image_method_final = 'krishnan';
kf_lambda=1e3; kf_exponent=2/3;
deconv_maxit_final = 25;

save_intermediate_images = 1;
% ============================================================================

% Now run the algorithm ======================================================
blind_deblur_map;
% ============================================================================
if isfield(params,'logfile'), fclose(logfile); end
end
