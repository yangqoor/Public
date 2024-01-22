% Function to create a structure containing parameters for Efficient Filter Flow
%    eff = makeEFF(size_sharp, theta_list, grid_size, Ksharp)

%	Author:		Oliver Whyte <oliver.whyte@ens.fr>
%	Date:		November 2011
%	Copyright:	2011, Oliver Whyte
%	Reference:  O. Whyte, J. Sivic and A. Zisserman. ``Deblurring Shaken and Partially Saturated Images''. In Proc. CPCV Workshop at ICCV, 2011.
%	URL:		http://www.di.ens.fr/willow/research/saturation/

function eff = makeEFF(size_sharp, theta_list, grid_size, Ksharp)

if isempty(grid_size)
    grid_size = [6 8];
end

if nargin < 4
    non_uniform = 0;
    kernel = theta_list;
    theta_list = [];
else
    non_uniform = 1;
end

% Size of PSF
if non_uniform
    pad_replicate = calculatePadding(size_sharp,non_uniform,theta_list,Ksharp);
else
    pad_replicate = calculatePadding(size_sharp,non_uniform,kernel);
end
h_psf = 1+2*(ceil(pad_replicate(1)+pad_replicate(2)+2)/2);
w_psf = 1+2*(ceil(pad_replicate(3)+pad_replicate(4)+2)/2);

h_sharp = size_sharp(1);
w_sharp = size_sharp(2);

% Set up grid of patches
if sign(h_sharp - w_sharp) ~= sign(grid_size(1) - grid_size(2))
    grid_size = grid_size([2,1]); 
end
h_grid = grid_size(1);
w_grid = grid_size(2);

if h_grid > 1
    h_patch_inner = ceil(h_sharp/(h_grid-1));       h_patch_inner = h_patch_inner-rem(h_patch_inner,2);
else
    h_patch_inner = h_sharp;
end
if w_grid > 1
    w_patch_inner = ceil(w_sharp/(w_grid-1));       w_patch_inner = w_patch_inner-rem(w_patch_inner,2);
else
    w_patch_inner = w_sharp;
end

% Choose padding to give power of two sizes for patches
%   If we have w_grid patches in the x-direction, we require 
%   that (w_grid-1)*w_patch > w_sharp. This ensures that Wsum==1 everywhere 
%   inside the image
pow_h_patch = nextpow2(h_patch_inner+h_psf);
pow_w_patch = nextpow2(w_patch_inner+w_psf);

% Calculate patch sizes and size of padded image
% NB patches will actaully be twice the size given by h_patch, w_patch, to give overlap
w_patch = 2^pow_w_patch;
h_patch = 2^pow_h_patch;

% Find pixels at the center of each patch
y_patch_centers = (1:h_grid)*h_patch_inner - h_patch_inner + h_patch + 1;
x_patch_centers = (1:w_grid)*w_patch_inner - w_patch_inner + w_patch + 1;

h_padded = y_patch_centers(end)+h_patch-1;
w_padded = x_patch_centers(end)+w_patch-1;

grid_size = [h_grid, w_grid];

pad_zero_t = floor((h_padded-h_sharp)/2);
pad_zero_b =  ceil((h_padded-h_sharp)/2);
pad_zero_l = floor((w_padded-w_sharp)/2);
pad_zero_r =  ceil((w_padded-w_sharp)/2);

if non_uniform
    % Adjust calibration matrices to take account of padding
    Ksharp  = htranslate([pad_zero_l ; pad_zero_t]) * Ksharp;

    % Just to be clear, Kblurry and Ksharp are the same
    Kblurry = Ksharp;
else
    Ksharp = eye(3);
    Kblurry = Ksharp;
end

if ~non_uniform
    kernel_inds_to_J_rows = round(ifft2(psf2otf(reshape(1:numel(kernel),size(kernel)),2*[h_patch,w_patch]),'symmetric'));
    % kernel_inds_to_J_rows = kernel_inds_to_J_rows(kernel_inds_to_J_rows~=0);
    J_uni = sparse(find(kernel_inds_to_J_rows), kernel_inds_to_J_rows(kernel_inds_to_J_rows(:)~=0), 1, 2*h_patch*2*w_patch, numel(kernel));
end
% Jacobians for producing local filters from blur kernel
J = cell(h_grid,w_grid);
for gx=1:w_grid
    l_patch(gx) = x_patch_centers(gx)-w_patch;
    r_patch(gx) = x_patch_centers(gx)+w_patch-1;
    for gy=1:h_grid
        t_patch(gy) = y_patch_centers(gy)-h_patch;
        b_patch(gy) = y_patch_centers(gy)+h_patch-1;
        if non_uniform
            J{gy,gx} = make_kernel_psf_jacobian_mex(2*[h_patch,w_patch],Ksharp,Kblurry,theta_list,[x_patch_centers(gx),y_patch_centers(gy)]);
        else
            J{gy,gx} = J_uni;
        end
        % Make sure each column of J sums to one
        J{gy,gx} = bsxfun(@rdivide, J{gy,gx}, sum(J{gy,gx}));
    end
end

% Windowing function -- weights over the middle portion, with zeros in the padding
W = barthannwin(2*h_patch_inner+1) * barthannwin(2*w_patch_inner+1)';
W = W(1:end-1,1:end-1);
W = padImage(W, [h_patch-h_patch_inner,h_patch-h_patch_inner,w_patch-w_patch_inner,w_patch-w_patch_inner]);
W2 = W.^2;
% Sum total weight for each pixel, since weights must sum to one when combining the FFTs
% Also sum weights squared -- useful when deblurring
Wsum = eps*ones(h_padded,w_padded);
W2sum = eps*ones(h_padded,w_padded);
for gx=1:w_grid
    for gy = 1:h_grid
        Wsum(t_patch(gy):b_patch(gy),l_patch(gx):r_patch(gx)) = Wsum(t_patch(gy):b_patch(gy),l_patch(gx):r_patch(gx)) + W;
        W2sum(t_patch(gy):b_patch(gy),l_patch(gx):r_patch(gx)) = W2sum(t_patch(gy):b_patch(gy),l_patch(gx):r_patch(gx)) + W2;
    end
end

eff = struct( ...
    'eff', 1, ...
    'grid_size', grid_size, ...
    'patch_size', [h_patch, w_patch], ...
    'patch_inner_size', [h_patch_inner, w_patch_inner], ...
    'padded_size', [h_padded, w_padded], ...
    'psf_size', [h_psf, w_psf], ...
    'W', W, ...
    'Wsum', Wsum, ...
    'W2sum', W2sum, ...
    'J', {J}, ...
    'pad', [pad_zero_t, pad_zero_b, pad_zero_l, pad_zero_r], ...
    't_patch', t_patch, ...
    'b_patch', b_patch, ...
    'l_patch', l_patch, ...
    'r_patch', r_patch, ...
    'Kblurry', Kblurry, ...
    'x_patch_centers', x_patch_centers, ...
    'y_patch_centers', y_patch_centers, ...
    'theta_list',theta_list, ...
    'n_kernel',size(theta_list,2));

