% kernel_stack = computeFilterStackEFF(eff, kernel, freq_out, [which_patches])

%	Author:		Oliver Whyte <oliver.whyte@ens.fr>
%	Date:		November 2011
%	Copyright:	2011, Oliver Whyte
%	Reference:  O. Whyte, J. Sivic and A. Zisserman. ``Deblurring Shaken and Partially Saturated Images''. In Proc. CPCV Workshop at ICCV, 2011.
%	URL:		http://www.di.ens.fr/willow/research/saturation/

function kernel_stack = computeFilterStackEFF(eff, kernel, freq_out, which_patches)

h_grid = eff.grid_size(1);
w_grid = eff.grid_size(2);
n_grid = prod(eff.grid_size);
h_patch = eff.patch_size(1);
w_patch = eff.patch_size(2);
h_psf = eff.psf_size(1);
w_psf = eff.psf_size(2);
J = eff.J;

kernel = kernel(:);

if ~exist('which_patches','var') || isempty(which_patches)
    which_patches = 1:n_grid;
else
    which_patches = which_patches(:)';
end
[gylist,gxlist] = ind2sub(eff.grid_size,which_patches);

% Compute stack of filters
kernel_stack = zeros(2*h_patch, 2*w_patch, 1, numel(which_patches));
for i = 1:length(which_patches)
    gx = gxlist(i);
    gy = gylist(i);
    psf = reshape(J{gy,gx}*kernel, 2*[h_patch, w_patch]);
    if sum(kernel(:)) ~= 0
        psf = psf / sum(psf(:)) * sum(kernel(:));
    end
    kernel_stack(:,:,:,i) = psf;
end

% Take FFT of stack of filters
if freq_out
    kernel_stack = fft2(kernel_stack);
end
