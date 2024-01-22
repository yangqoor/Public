% correlation = Btg_EFF(eff, imsharp[_fft], imblur[_fft])
%       if eff is already set-up, and images are already padded
%       if imblur or imsharp are complex, they are taken to be already in
%           the form of arrays of Fourier-transformed patches
% correlation = Btg_EFF(imsharp, imblur, theta_list, Ksharp)
%       nothing is setup or precomputed yet

%	Author:		Oliver Whyte <oliver.whyte@ens.fr>
%	Date:		November 2011
%	Copyright:	2011, Oliver Whyte
%	Reference:  O. Whyte, J. Sivic and A. Zisserman. ``Deblurring Shaken and Partially Saturated Images''. In Proc. CPCV Workshop at ICCV, 2011.
%	URL:		http://www.di.ens.fr/willow/research/saturation/

function Btg = Btg_EFF(varargin)
fft_conv = 1;
if isstruct(varargin{1})
    eff = varargin{1};
    imsharp = varargin{2};
    imblur = varargin{3};
    if ndims(imsharp) <= 3
        imsharp_fft = computeImageStackEFF(eff, imsharp, 'sharp', fft_conv);
    else
        imsharp_fft = imsharp;
    end
    if ndims(imblur) <= 3
        imblur_fft = computeImageStackEFF(eff, imblur, 'blurry', fft_conv);
    else
        imblur_fft = imblur;
    end
else
    imsharp = varargin{1};
    imblur = varargin{2};
    theta_list = varargin{3};
    Ksharp = varargin{4};
    grid_size = [6 8];
    eff = makeEFF(size(imsharp(:,:,1)), theta_list, grid_size, Ksharp);
    imsharp = padImage(imsharp, eff.pad, 0);
    imsharp_fft = computeImageStackEFF(eff, imsharp, 'sharp', fft_conv);
    imblur = padImage(imblur, eff.pad, 0);
    imblur_fft = computeImageStackEFF(eff, imblur, 'blurry', fft_conv);
end

h_padded = eff.padded_size(1);
w_padded = eff.padded_size(2);
channels = size(imsharp_fft,3);

h_grid = eff.grid_size(1);
w_grid = eff.grid_size(2);
n_grid = h_grid * w_grid;
h_patch = eff.patch_size(1);
w_patch = eff.patch_size(2);
h_psf = eff.psf_size(1);
w_psf = eff.psf_size(2);
t_patch = eff.t_patch;
b_patch = eff.b_patch;
l_patch = eff.l_patch;
r_patch = eff.r_patch;
J = eff.J;
n_kernel = size(eff.theta_list,2);

% Compute correlation with sharp patch over all translations, and sum over all channels
Btg_prod = conj(imsharp_fft) .* imblur_fft;
Btg_fft = sum(Btg_prod,3);
Btg_patches = ifft2(Btg_fft,'symmetric');

Btg_patches = reshape(Btg_patches, [], n_grid);

% Redistribute correlations back into global kernel space according to Jacobians
Btg = zeros(n_kernel,1);
gi = 0;
for gx=1:w_grid
    for gy = 1:h_grid
        gi = gi + 1;
        % Apply the change of variables back into global kernel elements and add
        Btg = Btg + J{gy,gx}'*Btg_patches(:,gi);
    end
end
