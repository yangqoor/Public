% im_stack = computeImageStackEFF(eff, im, 'sharp', freq_out, [which_patches])
%       for sharp image (i.e. weight pixels according to position)
% 
% im_stack = computeImageStackEFF(eff, im, 'blurry', freq_out, [which_patches])
%       for blurry image (i.e. don't weight pixels)
% 
% im_stack = computeImageStackEFF(eff, im, weights, freq_out, [which_patches])
%       weight pixels by weights
% 
%     which_patches is an optional list of patches to extract. default is to return all patches

%    Author:        Oliver Whyte <oliver.whyte@ens.fr>
%    Date:        November 2011
%    Copyright:    2011, Oliver Whyte
%    Reference:  O. Whyte, J. Sivic and A. Zisserman. ``Deblurring Shaken and Partially Saturated Images''. In Proc. CPCV Workshop at ICCV, 2011.
%    URL:        http://www.di.ens.fr/willow/research/saturation/

function [im_stack,weights] = computeImageStackEFF(eff, im, flag, freq_out, which_patches)

h_grid = eff.grid_size(1);
w_grid = eff.grid_size(2);
n_grid = prod(eff.grid_size);
h_patch = eff.patch_size(1);
w_patch = eff.patch_size(2);
h_patch_inner = eff.patch_inner_size(1);
w_patch_inner = eff.patch_inner_size(2);
t_patch = eff.t_patch;
b_patch = eff.b_patch;
l_patch = eff.l_patch;
r_patch = eff.r_patch;

[h,w,channels] = size(im);

if ~exist('which_patches','var') || isempty(which_patches)
    which_patches = 1:n_grid;
else
    which_patches = which_patches(:)';
end
[gylist,gxlist] = ind2sub(eff.grid_size,which_patches);

im_stack = zeros(2*h_patch, 2*w_patch, channels, numel(which_patches));

if ischar(flag)
    switch flag
    case 'sharp'
        weights = eff.W;
    case 'blurry'
        weights = 1;
    case 'deblur'
        weights = sqrt(eff.W);
    case 'hard'
        weights = padImage(ones(2*eff.patch_inner_size), [h_patch-h_patch_inner,h_patch-h_patch_inner,w_patch-w_patch_inner,w_patch-w_patch_inner],0);
    case 'nooverlap'
        weights = padImage(ones(eff.patch_inner_size), [h_patch-h_patch_inner/2,h_patch-h_patch_inner/2,w_patch-w_patch_inner/2,w_patch-w_patch_inner/2],0);
    end
else
    if (size(flag,1) ~= size(eff.W,1) || size(flag,2) ~= size(eff.W,2)) && numel(flag) ~= 1
        error('weights used to extract must match patch size, or be a single scalar')
    end
    weights = flag;
end
        

% Make stack of image patches
for i = 1:length(which_patches)
    gx = gxlist(i);
    gy = gylist(i);
    % Weight each pixel in each channel of the patch
    if weights == 1
        im_stack(:,:,:,i) = im(t_patch(gy):b_patch(gy),l_patch(gx):r_patch(gx),:);
    else
        im_stack(:,:,:,i) = bsxfun(@times, im(t_patch(gy):b_patch(gy),l_patch(gx):r_patch(gx),:), weights);
    end
end

if freq_out
    % Take FFT of stack
    im_stack = fft2(im_stack);
end
