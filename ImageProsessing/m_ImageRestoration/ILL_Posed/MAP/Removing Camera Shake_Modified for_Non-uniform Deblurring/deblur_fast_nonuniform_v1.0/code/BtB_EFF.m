
%	Author:		Oliver Whyte <oliver.whyte@ens.fr>
%	Date:		November 2011
%	Copyright:	2011, Oliver Whyte
%	Reference:  O. Whyte, J. Sivic and A. Zisserman. ``Deblurring Shaken and Partially Saturated Images''. In Proc. CPCV Workshop at ICCV, 2011.
%	URL:		http://www.di.ens.fr/willow/research/saturation/

function [BtB,Btg] = BtB_EFF(varargin)
fft_conv = true;
sequential = true;
if isstruct(varargin{1})
    eff = varargin{1};
    imsharp = varargin{2};
    imblur = varargin{3};
    mask = varargin{4};
    if ndims(imsharp) <= 3
        if sequential
            % Anonymous function to compute one patch from the stack
            imsharp_fft      = @(p) computeImageStackEFF(eff, imsharp, 'sharp',  fft_conv, p);
            imsharp_full_fft = @(p) computeImageStackEFF(eff, bsxfun(@times,imsharp,mask), 'blurry', fft_conv, p);
            imblur_fft       = @(p) computeImageStackEFF(eff, bsxfun(@times,imblur,mask),  'blurry', fft_conv, p);
        else
            % Precompute the whole stack of patches
            imsharp_fft      = computeImageStackEFF(eff, imsharp, 'sharp',  fft_conv);
            imsharp_full_fft = computeImageStackEFF(eff, bsxfun(@times,imsharp,mask), 'blurry', fft_conv);
            imblur_fft       = computeImageStackEFF(eff, bsxfun(@times,imblur,mask),  'blurry', fft_conv);
        end
    else
        if sequential
            % Anonymous function to get one slice of the stack
            imsharp_fft = @(p) imsharp(:,:,:,p);
        else
            imsharp_fft = imsharp;
        end
    end
else
    imsharp = varargin{1};
    imblur  = varargin{2};
    theta_list = varargin{3};
    Ksharp = varargin{4};
    mask = varargin{5};
    grid_size = [6 8];
    eff = makeEFF(size(imsharp(:,:,1)), theta_list, grid_size, Ksharp);
    imsharp = padImage(imsharp, eff.pad, 0);
    imblur  = padImage(imblur , eff.pad, 0);
    mask    = padImage(mask   , eff.pad, 0);
    if sequential
        % Anonymous function to compute one patch from the stack
        imsharp_fft      = @(p) computeImageStackEFF(eff, imsharp, 'sharp', fft_conv, p);
        imsharp_full_fft = @(p) computeImageStackEFF(eff, bsxfun(@times,imsharp,mask), 'blurry', fft_conv, p);
        imblur_fft       = @(p) computeImageStackEFF(eff, bsxfun(@times,imblur,mask), 'blurry', fft_conv, p);
    else
        % Precompute the whole stack of patches
        imsharp_fft      = computeImageStackEFF(eff, imsharp, 'sharp', fft_conv);
        imsharp_full_fft = computeImageStackEFF(eff, bsxfun(@times,imsharp,mask), 'blurry', fft_conv);
        imblur_fft       = computeImageStackEFF(eff, bsxfun(@times,imblur,mask), 'blurry', fft_conv);
    end
end

h_grid = eff.grid_size(1);
w_grid = eff.grid_size(2);
n_grid = prod(eff.grid_size);
h_patch = eff.patch_size(1);
w_patch = eff.patch_size(2);
n_kernel = size(eff.theta_list,2);
J = eff.J;

BtB = zeros(eff.n_kernel,eff.n_kernel);
Btg = zeros(n_kernel,1);

if sequential
    % Precompute offsets for spatially-invariant filter elements once
    h = 2*h_patch; % real size of a patch
    w = 2*w_patch;
    [dx,dy] = meshgrid(0:w-1,0:h-1);
    dx(:,ceil(w/2)+1:w) = dx(:,ceil(w/2)+1:w)-w;
    dy(ceil(h/2)+1:h,:) = dy(ceil(h/2)+1:h,:)-h;
    % Find non-zero rows in J -- don't need to get cross correlation anywhere else
    [ndx,tmp] = find(cat(2,J{:}));
    ndx = unique(ndx);
    nndx = numel(ndx);
    % Construct indices to convert autocorrelation vector to autocorrelation matrix
    xij = bsxfun(@minus,dx(ndx)',dx(ndx)) + 1;
    yij = bsxfun(@minus,dy(ndx)',dy(ndx)) + 1;
    xij(xij<1) = xij(xij<1) + w;
    yij(yij<1) = yij(yij<1) + h;
    ijind = xij*h - h + yij;
    for gi=1:n_grid
        % Get patches
        imsharp_fft_patch = imsharp_fft(gi);
        imsharp_full_fft_patch = imsharp_full_fft(gi);
        % Compute BtB for patch in frequency domain, sum over all channels
        imsharp2_fft_patch = sum(conj(imsharp_fft_patch) .* imsharp_full_fft_patch,3);
        % Get auto-correlation of patch
        autocorr = ifft2(imsharp2_fft_patch,'symmetric');
        if ~isequal([h,w],size(autocorr)), error('Size error'); end
        % Convert autocorrelation vector to autocorrelation matrix
        BrtBr = reshape(autocorr(ijind),[nndx,nndx]); %cc(ijind);
        % Convert the 2D auto-correlations to the camera rotation parameter space, and add to global spatially-variant auto-correlation matrix
        BtB = BtB + J{gi}(ndx,:)'*BrtBr*J{gi}(ndx,:);
        % Also compute B' * g
        imblur_fft_patch = imblur_fft(gi);
        % Compute correlation with sharp patch over all translations, and sum over all channels
        Btg_fft_patch = sum(conj(imsharp_fft_patch) .* imblur_fft_patch,3);
        Btg_patch = ifft2(Btg_fft_patch,'symmetric');
        % Apply the change of variables back into camera rotation space and add
        Btg = Btg + J{gi}'*Btg_patch(:);
    end
else
    % precompute BtB in frequency domain
    imsharp2_fft = sum(conj(imsharp_fft) .* imsharp_full_fft,3);

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
    % Also compute B' * g
    Btg = Btg_EFF(eff, imsharp_fft, imblur_fft);
end

% Ensure symmetry
BtB = 0.5*(BtB + BtB');

