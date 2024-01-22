% [im,weights] = recombineImageStackEFF(eff, im_stack, flag, freq_in, [im_init], [which_patches])
% 
% [im,weights] = recombineImageStackEFF(eff, im_stack, weights, freq_in, [im_init], [which_patches])

%    Author:        Oliver Whyte <oliver.whyte@ens.fr>
%    Date:        November 2011
%    Copyright:    2011, Oliver Whyte
%    Reference:  O. Whyte, J. Sivic and A. Zisserman. ``Deblurring Shaken and Partially Saturated Images''. In Proc. CPCV Workshop at ICCV, 2011.
%    URL:        http://www.di.ens.fr/willow/research/saturation/

function [im,weights] = recombineImageStackEFF(eff, im_stack, flag, freq_in, im, which_patches)

if nargin < 4 || isempty(freq_in)
    freq_in = false;
end
    
h_grid = eff.grid_size(1);
w_grid = eff.grid_size(2);
n_grid = prod(eff.grid_size);
h_padded = eff.padded_size(1);
w_padded = eff.padded_size(2);
h_patch = eff.patch_size(1);
w_patch = eff.patch_size(2);
t_patch = eff.t_patch;
b_patch = eff.b_patch;
l_patch = eff.l_patch;
r_patch = eff.r_patch;

if isempty(im_stack)
    if ~exist('im','var') || isempty(im)
        error('Must provide either some patches or an image')
    end
    % If im_stack is empty, just perform the final re-weighting of pixels
    if strcmp(flag, 'deblurnew')
        % Divide through by sum_r C_r' * (W.^2)
        im = bsxfun(@rdivide, im, eff.W2sum);
    end
else
    % Else, add the provided patches to the image
    channels = size(im_stack,3);
    if ~exist('which_patches','var') || isempty(which_patches)
        which_patches = 1:n_grid;
    else
        which_patches = which_patches(:)';
    end
    [gylist,gxlist] = ind2sub(eff.grid_size,which_patches);

    if freq_in
        % Take FFT of stack
        im_stack = ifft2(im_stack,'symmetric');
    end

    if ~exist('im','var') || isempty(im)
        im = zeros(h_padded,w_padded,channels);
    end

    % Make weights for recombining patches
    if ischar(flag)
        switch flag
        case 'sharp'
            weights = eff.W;
        case 'blurry'
            weights = 1;
        case 'deblur'
            weights = sqrt(eff.W);
        case 'deblurnew'
            weights = eff.W;
        end
    else
        if (size(flag,1) ~= size(eff.W,1) || size(flag,2) ~= size(eff.W,2)) && numel(flag) ~= 1
            error('weights used to extract must match patch size, or be a single scalar')
        end
        weights = flag;
    end

    % Add patches to the image
    for i = 1:length(which_patches)
        gx = gxlist(i);
        gy = gylist(i);
        % Weight each pixel in each channel of the patch and add to image
        if weights == 1
            im(t_patch(gy):b_patch(gy),l_patch(gx):r_patch(gx),:) = im(t_patch(gy):b_patch(gy),l_patch(gx):r_patch(gx),:) + im_stack(:,:,:,i);
        else
            im(t_patch(gy):b_patch(gy),l_patch(gx):r_patch(gx),:) = im(t_patch(gy):b_patch(gy),l_patch(gx):r_patch(gx),:) + bsxfun(@times, im_stack(:,:,:,i), weights);
        end
    end
    
    % If we got a full stack, do the final re-weighting now
    if length(which_patches)==n_grid && strcmp(flag, 'deblurnew')
        % Divide through by sum_r C_r' * (W.^2)
        im = bsxfun(@rdivide, im, eff.W2sum);
    end
end
