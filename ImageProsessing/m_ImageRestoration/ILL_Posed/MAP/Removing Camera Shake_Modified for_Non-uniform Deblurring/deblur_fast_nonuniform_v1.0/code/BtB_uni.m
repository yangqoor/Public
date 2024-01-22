
%	Author:		Oliver Whyte <oliver.whyte@ens.fr>
%	Date:		November 2011
%	Copyright:	2011, Oliver Whyte
%	Reference:  O. Whyte, J. Sivic and A. Zisserman. ``Deblurring Shaken and Partially Saturated Images''. In Proc. CPCV Workshop at ICCV, 2011.
%	URL:		http://www.di.ens.fr/willow/research/saturation/

function [BtB,Btg] = BtB_uni(varargin)
imsharp = varargin{1};
imblur  = varargin{2};
kernel_size = varargin{3};

pad = 2*calculatePadding(size(imsharp),0,zeros(kernel_size));

imsharp = padImage(imsharp, pad, 0);
imblur  = padImage(imblur , pad, 0);

imsharp_fft = fft2(imsharp);
imblur_fft  = fft2(imblur);

% precompute BtB in frequency domain
imsharp2_fft = sum(conj(imsharp_fft) .* imsharp_fft,3);

h_grid = eff.grid_size(1);
w_grid = eff.grid_size(2);
n_grid = prod(eff.grid_size);
J = eff.J;

BtB = zeros(eff.n_kernel,eff.n_kernel);

% Get auto-correlation of each patch
autocorr = ifft2(imsharp2_fft,'symmetric');
[h,w] = size(autocorr(:,:,1));
autocorr = reshape(autocorr,[],n_grid);
[dx,dy] = meshgrid(0:w-1,0:h-1);
dx(:,ceil(w/2)+1:w) = dx(:,ceil(w/2)+1:w)-w;
dy(ceil(h/2)+1:h,:) = dy(ceil(h/2)+1:h,:)-h;
% Find non-zero rows in J -- don't need to get cross correlation anywhere else
[ndx,tmp] = find(cat(2,J{:}));
ndx = unique(ndx);
nndx = numel(ndx);
xij = bsxfun(@minus,dx(ndx)',dx(ndx)) + 1;
yij = bsxfun(@minus,dy(ndx)',dy(ndx)) + 1;
xij(xij<1) = xij(xij<1) + w;
yij(yij<1) = yij(yij<1) + h;
ijind = xij*h - h + yij;
% Convert the 2D auto-correlations to the camera rotation parameter space
BrtBr = reshape(autocorr(ijind,:),nndx,nndx,n_grid); %cc(ijind);
for gi=1:n_grid
    BtB = BtB + J{gi}(ndx,:)'*BrtBr(:,:,gi)*J{gi}(ndx,:);
end
BtB = 0.5*(BtB + BtB');

% Also compute B' * g
Btg = Btg_EFF(eff, imsharp_fft, imblur_fft);
