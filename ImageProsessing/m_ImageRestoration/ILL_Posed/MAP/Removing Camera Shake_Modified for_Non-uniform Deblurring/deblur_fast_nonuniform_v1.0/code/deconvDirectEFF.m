% imout = deconvDirectEFF(imblur, kernel, non_uniform=1, theta_list, Kblur, alpha, [grid_size], [mask])
% imout = deconvDirectEFF(imblur, kernel, non_uniform=0, alpha, [mask])
%   Direct frequency-domain deconvolution of blurry image, deconvolving each 
%   EFF patch independently, then finding optimal sharp image which fits the patches

%	Author:		Oliver Whyte <oliver.whyte@ens.fr>
%	Date:		November 2011
%	Copyright:	2011, Oliver Whyte
%	Reference:  O. Whyte, J. Sivic and A. Zisserman. ``Deblurring Shaken and Partially Saturated Images''. In Proc. CPCV Workshop at ICCV, 2011.
%	URL:		http://www.di.ens.fr/willow/research/saturation/

function imout = deconvDirectEFF(imblur, kernel, non_uniform, theta_list, Kblur, alpha, grid_size, mask)
sequential = true;
oldway = false;
if oldway
    disp('Warning: using old direct deconvolution code')
    extractweights = 'deblur';
    combineweights = 'deblur';
else
    extractweights = 'sharp';
    combineweights = 'deblurnew';
end

if ~non_uniform
    alpha = theta_list;
    if nargin>=5
        mask = Kblur;
    end
end

if non_uniform
    theta_list = theta_list(:,kernel~=0);
    kernel = kernel(kernel~=0);
    kernel = kernel/sum(kernel(:));
end

if ~exist('grid_size','var') || isempty(grid_size)
    if non_uniform
        grid_size = [6 8]; 
    else
        grid_size = [1 1];
    end
end

if non_uniform
    [pad_replicate, Kblur] = calculatePadding(size(imblur),non_uniform,theta_list,Kblur);
else
    pad_replicate = 4*calculatePadding(size(imblur),non_uniform,kernel);
end

imblur = padImage(imblur, pad_replicate, 'replicate');

if non_uniform
    eff = makeEFF(size(imblur), theta_list, grid_size, Kblur);
else
    eff = makeEFF(size(imblur), kernel, grid_size);
end

imblur = padImage(imblur, eff.pad, 'replicate');

pad = pad_replicate + eff.pad;

if sequential
    % Anonymous function to compute one local PSF
    kernel_stack = @(p) computeFilterStackEFF(eff, kernel, 1, p);
else
    % Precompute whole stack of local PSFs
    kernel_stack = computeFilterStackEFF(eff, kernel, 1);
end


n_grid = prod(eff.grid_size);
h_patch = eff.patch_size(1);
w_patch = eff.patch_size(2);
h = 2*h_patch; % real size of a patch
w = 2*w_patch;

if exist('mask','var') && ~isempty(mask)
    % Take mask of saturated pixel in sharp image
    mask = padImage(mask, pad, 1);
    mask = imerode(mask, ones(5));
    % Interpolate regions in blurry image
    imblur = poisson_blend_backslash(zeros(size(imblur)),zeros(size(imblur)),imblur,mask);
end

denom2 = abs(psf2otf([1,-1],[h w])).^2 + abs(psf2otf([1;-1],[h w])).^2;

if sequential
    imout = [];
    for gi=1:n_grid
        kernel_patch = kernel_stack(gi);
        imblur_patch = computeImageStackEFF(eff, imblur, extractweights, 1, gi);
        numer = bsxfun(@times, imblur_patch, conj(kernel_patch));
        denom1 = abs(kernel_patch).^2;
        denom = bsxfun(@plus, denom1, alpha*denom2);
        imout_patch = bsxfun(@rdivide, numer, denom);
        imout = recombineImageStackEFF(eff, imout_patch, combineweights, 1, imout, gi);
    end
    % Perform final weighting
    imout = recombineImageStackEFF(eff, [], combineweights, 1, imout, []);
else
    imblur_stack = computeImageStackEFF(eff, imblur, extractweights, 1);
    % if non_uniform
    %     % Blur imblur again to reduce ringing
    %     % imblur2_stack = bsxfun(@times, imblur_stack, kernel_stack);
    %     % imblur_stack = fft2(bsxfun(@times,ifft2(imblur_stack,'symmetric'),eff.W) + bsxfun(@times,ifft2(imblur2_stack,'symmetric'),1-eff.W));
    % else
    %     imblur_stack = computeImageStackEFF(eff, imblur, extractweights, 1);
    %     % imblur_stack = fft2(imblur);
    % end

    numer = bsxfun(@times, imblur_stack, conj(kernel_stack));

    denom1 = abs(kernel_stack).^2;
    denom = bsxfun(@plus, denom1, alpha*denom2);

    imout_stack = bsxfun(@rdivide, numer, denom); 

    imout = recombineImageStackEFF(eff, imout_stack, combineweights, 1);
end

imout = padImage(imout, -pad);

