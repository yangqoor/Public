% i_rl = deconvRL(imblur, kernel, non_uniform, ...)
%       for uniform blur, with non_uniform = 0
% 
% i_rl = deconvRL(imblur, kernel, non_uniform, theta_list, Kblurry, ...)
%       for non-uniform blur, with non_uniform = 1
% 
% Additional arguments, in any order:
%   ... , 'forward_saturation', ...    use forward model for saturation
%   ... , 'prevent_ringing', ...       split and re-combine updates to reduce ringing
%   ... , 'eff', ...                   use EFF approximation to spatially-variant blur
%   ... , 'eff_grid', [h w], ...       resolution of EFF grid (default is [6 8])
%   ... , 'sat_thresh', T, ...         clipping level for forward model of saturation (default is 1.0)
%   ... , 'sat_smooth', a, ...         smoothness parameter for forward model (default is 50)
%   ... , 'num_iters', n, ...          number of iterations (default is 50)
%   ... , 'init', im_init, ...         initial estimate of deblurred image (default is blurry image)
%   ... , 'mask', mask, ...            binary mask of blurry pixels to use -- 1=use, 0=discard -- (default is all blurry pixels, ie. 1 everywhere)
%   ... , 'reg', reg_method, ...       regularisation method -- 'l1', 'none' (default is 'none')
%   ... , 'reg_weight', alpha, ...     regularisation weight -- mandatory if 'reg' is not 'none'

%	Author:		Oliver Whyte <oliver.whyte@ens.fr>
%	Date:		November 2011
%	Copyright:	2011, Oliver Whyte
%	Reference:  O. Whyte, J. Sivic and A. Zisserman. "Deblurring Shaken and Partially Saturated Images". In Proc. CPCV Workshop at ICCV, 2011.
%	URL:		http://www.di.ens.fr/willow/research/saturation/

function i_rl = deconvRL(imblur,kernel,non_uniform,varargin)
if nargin < 3, non_uniform = 0; end

% Parse varargin
if non_uniform
    theta_list = varargin{1};
    Kblurry = varargin{2};
    varargin = varargin(3:end);
    % Remove the zero elements of kernel
    use_rotations = kernel(:) ~= 0;
    kernel = kernel(use_rotations);
    theta_list = theta_list(:,use_rotations);
end
params = parseArgs(varargin);

kernel = kernel / sum(kernel(:));

% Get image size
[h,w,channels] = size(imblur);

% Calculate padding based on blur kernel size
if non_uniform
    [pad_replicate, Kblurry] = calculatePadding([h,w],non_uniform,theta_list,Kblurry);
else
    pad_replicate = calculatePadding([h,w],non_uniform,kernel);
end

% Pad blurry image by replication to handle edge effects
imblur = padImage(imblur, pad_replicate, 'replicate');

if non_uniform && params.eff
    % Setup EFF
    fft_conv = 1;
    fprintf('making eff...')
    eff = makeEFF(size(imblur), theta_list, params.eff_grid, Kblurry);
    fprintf('done\n')
    Kblurry = eff.Kblurry;
    % Pad image with zeros for EFF
    imblur = padImage(imblur, eff.pad, 0);
    pad = pad_replicate + eff.pad;
    % Precompute FFT of all local filters
    filt_stack = computeFilterStackEFF(eff, kernel, fft_conv);
    filt1_stack = computeFilterStackEFF(eff, ones(size(kernel)), fft_conv);
else
    pad = pad_replicate;
end

% Get new image size
[h,w,channels] = size(imblur);

% Define blur functions depending on blur type
if non_uniform
    if params.eff
        blurfn  = @(im) blurEFF(eff, im, filt_stack,  'conv', fft_conv);
        conjfn  = @(im) blurEFF(eff, im, filt_stack,  'corr', fft_conv);
        dilatefn = @(im) min(blurEFF(eff, im, filt1_stack, 'conv', fft_conv), 1);
    else
        Ksharp = Kblurry;
        blurfn  = @(im) apply_blur_kernel_mex(double(im),[h,w],Ksharp,Kblurry,-theta_list,kernel,0,non_uniform);
        conjfn  = @(im) apply_blur_kernel_mex(double(im),[h,w],Kblurry,Ksharp, theta_list,kernel,0,non_uniform);
        dilatefn = @(im) min(apply_blur_kernel_mex(double(im),[h,w],Ksharp,Kblurry,-theta_list,ones(size(kernel)),0,non_uniform), 1);
    end
else
    % blurfn  = @(im) imfilter(im,kernel,'conv');
    % conjfn  = @(im) imfilter(im,kernel,'corr');
    % dilatefn = @(im) min(imfilter(im,double(kernel~=0),'conv'), 1);
    kfft  = psf2otf(kernel,[h w]);
    k1fft = psf2otf(double(kernel~=0),[h w]);
    blurfn  = @(im) ifft2(bsxfun(@times,fft2(im),kfft),'symmetric');
    conjfn  = @(im) ifft2(bsxfun(@times,fft2(im),conj(kfft)),'symmetric');
    dilatefn = @(im) min(ifft2(bsxfun(@times,fft2(im),k1fft),'symmetric'), 1);
end

% Mask of "good" blurry pixels
mask = zeros(h,w,channels);
mask(pad(1)+1:h-pad(2),pad(3)+1:w-pad(4),:) = params.mask;
if params.eff
    unpaddedmask = zeros(h,w);
    unpaddedmask(eff.pad(1)+1:h-eff.pad(2),eff.pad(3)+1:w-eff.pad(4)) = 1;
else
    unpaddedmask = ones(h,w);
end

% Initialise sharp image
if isfield(params,'init') && ~isempty(params.init)
    i_rl = padImage(double(params.init),pad_replicate,'replicate');
    if non_uniform && params.eff
        i_rl = padImage(i_rl,eff.pad,0);
    end
else
    i_rl = imblur;
end

fprintf('%d iterations: ',params.num_iters);

% Some fixed filters for dilation and smoothing
dilate_radius = 3;
dilate_filter = bsxfun(@plus,(-dilate_radius:dilate_radius).^2,(-dilate_radius:dilate_radius)'.^2) <= eps+dilate_radius.^2;
smooth_filter = fspecial('gaussian',[21 21],3);

% Regularisation setup
switch params.reg
case {'l1','lp'}
    kx = [-1,1,0];  ky = kx';
    dxmask  = repmat(imerode(unpaddedmask,ones(3)), [1 1 channels]);
    dxmask([1 end],:,:) = 0; dxmask(:,[1 end],:) = 0;
    dymask  = dxmask;
    dxtmask = dxmask;
    dytmask = dxmask;
case 'none'
otherwise
    warning('unknown regularisation method, using ''none'' instead');
    params.reg = 'none';
end

params.reg_weight_rate = (params.reg_weight_end - params.reg_weight) / params.num_iters;

% Main algorithm loop
for iter = 1:params.num_iters
    % Apply the linear forward model first (ie. compute A*f)
    val_linear = max(blurfn(i_rl),0);
    % Apply non-linear response if required
    if params.forward_saturation
        [val_nonlin,grad_nonlin] = saturate(val_linear,params.sat_thresh,params.sat_smooth);
    else
        val_nonlin  = val_linear;
        grad_nonlin = 1;
    end
    % Compute the raw error ratio for the current estimate of the sharp image
    error_ratio = imblur ./ max(val_nonlin,eps);
    error_ratio_masked_nonlin = (error_ratio - 1).*mask.*grad_nonlin;
    if params.prevent_ringing
        % Find hard-to-estimate pixels in sharp image (set S in paper)
        S_mask = double(imdilate(i_rl >= 0.9, dilate_filter));
        % Find the blurry pixels NOT influenced by pixels in S (set V in paper)
        V_mask = 1 - dilatefn(S_mask);
        % Apply conjugate blur function (ie. multiply by A')
        update_ratio_U = conjfn(error_ratio_masked_nonlin.*V_mask) + 1; % update U using only data from V
        update_ratio_S = conjfn(error_ratio_masked_nonlin)         + 1; % update S using all data
        % Blur the mask of hard-to-estimate pixels for recombining without artefacts
        weights = imfilter(S_mask, smooth_filter);
        % Combine updates for the two sets into a single update
        % update_ratio = update_ratio_S.*weights + update_ratio_U.*(1-weights);
        update_ratio = update_ratio_U + (update_ratio_S - update_ratio_U).*weights;
    else
        % Apply conjugate blur function (ie. multiply by A')
        update_ratio = conjfn(error_ratio_masked_nonlin) + 1;
    end
    % Add regularisation
    switch params.reg
    case {'l1','lp'}
        % l1 or sps on gradients after gamma correction
        % Dxf  = sign(imfilter(i_rl,kx,'conv').*dxmask);
        % Dyf  = sign(imfilter(i_rl,ky,'conv').*dymask);
        Dxf  = imfilter(i_rl,kx,'conv').*dxmask;
        Dyf  = imfilter(i_rl,ky,'conv').*dymask;
        tmpx = params.sps_exp*(eps+abs(Dxf)).^(params.sps_exp-1).*sign(Dxf);
        tmpy = params.sps_exp*(eps+abs(Dyf)).^(params.sps_exp-1).*sign(Dyf);
        DxtDxf = imfilter(tmpx,kx,'corr').*dxtmask;
        DytDyf = imfilter(tmpy,ky,'corr').*dytmask;
        grad_reg = DxtDxf + DytDyf;
    otherwise
        grad_reg = 0;
    end
    % Modify update ratio according to regulariser
    update_ratio = update_ratio ./ (1 + params.reg_weight*grad_reg);
    % Avoid negative updates, which cause trouble
    update_ratio = max(update_ratio,0);
    if any(isnan(update_ratio(:))), error('NaNs in update ratio'); end
    % Apply update ratio
    i_rl = update_ratio .* i_rl;
    fprintf('%d ',iter);
    % Change regularisation weight?
    params.reg_weight = params.reg_weight + params.reg_weight_rate;
end
fprintf('\n');

% Remove padding on output image
i_rl = padImage(i_rl, -pad);

end

% =====================================================================================

function params = parseArgs(args,params)
if nargin < 2
    params = struct('num_iters',50,'eff',0,'eff_grid',[6 8],'forward_saturation',false,'prevent_ringing',false,'sat_thresh',1,'sat_smooth',50,'mask',1,'reg','none','reg_weight',0);
end
if ~isempty(args)
	switch args{1}
	case 'eff'
		params.eff = 1;
		args = args(2:end);
	case 'num_iters'
		params.num_iters = args{2};
		args = args(3:end);
	case 'eff_grid'
	    params.eff_grid = args{2};
		args = args(3:end);
	case 'sat_thresh'
	    params.sat_thresh = args{2};
	    args = args(3:end);
	case 'sat_smooth'
	    params.sat_smooth = args{2};
	    args = args(3:end);
	case 'forward_saturation'
		params.forward_saturation = true;
		args = args(2:end);
	case 'prevent_ringing'
		params.prevent_ringing = true;
		args = args(2:end);
    case 'init'
	    params.init = args{2};
	    args = args(3:end);
    case 'mask'
        params.mask = args{2};
	    args = args(3:end);
    case 'reg'
        params.reg = args{2};
	    args = args(3:end);
    case 'sps_exp'
        params.sps_exp = args{2};
	    args = args(3:end);
	case 'reg_weight'
        params.reg_weight = args{2};
	    args = args(3:end);
	case 'reg_weight_end'
        params.reg_weight_end = args{2};
	    args = args(3:end);
	otherwise
		error('Invalid argument');
	end
    % Recursively parse remaining arguments
	params = parseArgs(args,params);
end
% Check arguments in the root call
if nargin < 2
    switch params.reg
    case 'l1'
        params.sps_exp = 1;
    case 'lp'
        if ~isfield(params,'sps_exp'), error('Must specifiy sps_exp for exponent for sparse gradient regularisation'); end
    end
    if ~isfield(params,'reg_weight_end')
        params.reg_weight_end = params.reg_weight;
    end
end
end

% ============================================================================

function [val,grad] = saturate(x,t,a)
if a==inf
    [val,grad] = sharpsaturate(x, t);
else
    % Adapted from: C. Chen and O. L. Mangasarian. ``A Class of Smoothing Functions
    %               for Nonlinear and Mixed Complementarity Problems''. 
    %               Computational Optimization and Applications, 1996.
    one_p_exp = 1 + exp(-a*(t-x));
    val = x - 1/a * log(one_p_exp);
    grad = 1 ./ one_p_exp;
end
end

% ============================================================================

function [val,grad] = sharpsaturate(x,t)
val = x;
grad = ones(size(x));

mask = x>t;
val(mask) = t;
grad(mask) = 0;

end