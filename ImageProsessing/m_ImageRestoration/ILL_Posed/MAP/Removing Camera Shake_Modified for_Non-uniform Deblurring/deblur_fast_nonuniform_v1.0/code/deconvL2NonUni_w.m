% [x,pad]=deconvL2NonUni_w(imblur,kernel,we,max_it,weight_x,weight_y,weight_xx,weight_yy,weight_xy,non_uniform = 0)
% [x,pad]=deconvL2NonUni_w(imblur,kernel,we,max_it,weight_x,weight_y,weight_xx,weight_yy,weight_xy,non_uniform = 0,saturation_mask,iminit)
% [x,pad]=deconvL2NonUni_w(imblur,kernel,we,max_it,weight_x,weight_y,weight_xx,weight_yy,weight_xy,non_uniform = 1,saturation_mask,iminit,theta_s,K,use_eff)

% Derived from Sparse Deconvolution code by Levin et al.
%   see http://groups.csail.mit.edu/graphics/CodedAperture/ for more details
% Modification for non-uniform blur by Oliver Whyte, 2011

function [x,pad]=deconvL2NonUni_w(imblur,kernel,we,max_it,weight_x,weight_y,weight_xx,weight_yy,weight_xy,non_uniform,saturation_mask,iminit,theta_s,K,use_eff)


if ~exist('saturation_mask','var') || isempty(saturation_mask), saturation_mask = 1; end
if ~exist('iminit','var') || isempty(iminit), iminit=imblur; end
if ~exist('max_it','var'), max_it=200; end
if ~exist('use_eff','var') || isempty(use_eff), use_eff = false; end

[n,m,channels]=size(imblur);

if non_uniform
    % Remove zero kernel elements
    theta_s = theta_s(:,kernel~=0);
    kernel = kernel(kernel~=0);
    [pad_replicate, K] = calculatePadding([n,m],non_uniform,theta_s,K);
else
    pad_replicate = calculatePadding([n,m],non_uniform,kernel);
end

% image padded with edge values propagated outwards
imblur = padImage(imblur, pad_replicate, 'replicate');
iminit = padImage(iminit, pad_replicate, 'replicate');

if non_uniform
    if use_eff
        eff = makeEFF(size(imblur(:,:,1)), theta_s, [], K);
        fft_conv = 1;
        % pad_replicate image with zeros for EFF
        imblur = padImage(imblur, eff.pad, 0);
        iminit = padImage(iminit, eff.pad, 0);
        pad = pad_replicate + eff.pad;
        % pad images
        m = m + pad(3) + pad(4);
        n = n + pad(1) + pad(2);
        % Precompute FFT of all local filters
        filt_stack = computeFilterStackEFF(eff, kernel, fft_conv);
        % Define blunr function and conjugate blur function
        blurfn = @(im) blurEFF(eff, im, filt_stack, 'conv', fft_conv);
        conjfn = @(im) blurEFF(eff, im, filt_stack, 'corr', fft_conv);
    else
        pad = pad_replicate;
        clamp_edges_to_zero = 0;
        % pad images
        m = m + pad(3) + pad(4);
        n = n + pad(1) + pad(2);
        % Define blunr function and conjugate blur function
        blurfn = @(im) apply_blur_kernel_mex(double(im),[n,m],K,K,-theta_s,kernel,clamp_edges_to_zero,non_uniform,[0;0;0]);
        conjfn = @(im) apply_blur_kernel_mex(double(im),[n,m],K,K, theta_s,kernel,clamp_edges_to_zero,non_uniform,[0;0;0]);
    end
else
    pad = pad_replicate;
    % pad images
    m = m + pad(3) + pad(4);
    n = n + pad(1) + pad(2);
    % Define blunr function and conjugate blur function
    blurfn = @(im) imfilter(double(im),kernel,'same','conv');
    conjfn = @(im) imfilter(double(im),kernel,'same','corr');
end

mask = zeros(n,m,channels);
mask(pad(1)+1:n-pad(2),pad(3)+1:m-pad(4),:) = saturation_mask;
mask = imerode(mask,ones(5)); mask([1 end],:,:) = 0; mask(:,[1 end],:) = 0;

x = iminit;

dxf=[1 -1];
dyf=[1;-1];
dyyf=[-1; 2; -1];
dxxf=[-1, 2, -1];
dxyf=[-1 1;1 -1];

% Define a function to filter colour images using conv2
eval(['colourconv2 = @(im,h,sz) cat(3' sprintf(',conv2(im(:,:,%d),h,sz)',1:channels) ');']);


DtBall = imblur;






ax = blurfn(x);

DtDax = ax;






r = conjfn(DtBall.*mask - DtDax.*mask);
r = r - we*colourconv2( weight_x.*colourconv2(x,fliplr(flipud(dxf)) ,'valid'),dxf ,'full');
r = r - we*colourconv2( weight_y.*colourconv2(x,fliplr(flipud(dyf)) ,'valid'),dyf ,'full');
r = r - we*colourconv2(weight_xx.*colourconv2(x,fliplr(flipud(dxxf)),'valid'),dxxf,'full');
r = r - we*colourconv2(weight_yy.*colourconv2(x,fliplr(flipud(dyyf)),'valid'),dyyf,'full');
r = r - we*colourconv2(weight_xy.*colourconv2(x,fliplr(flipud(dxyf)),'valid'),dxyf,'full');

d = r; % initial direction
% rho = (r(:)'*r(:));
rho = squeeze(sum(sum(r.^2,1),2));
if rho<eps, return; end
fprintf('%d iterations: ',max_it);
for iter = 1:max_it  
     Ad = blurfn(d);

     DtDAd = Ad;





     % Apply Atranspose
     AtDtDAd = conjfn(DtDAd.*mask);
     AtDtDAd = AtDtDAd + we*colourconv2( weight_x.*colourconv2(d,fliplr(flipud(dxf)) ,'valid'),dxf ,'full');
     AtDtDAd = AtDtDAd + we*colourconv2( weight_y.*colourconv2(d,fliplr(flipud(dyf)) ,'valid'),dyf ,'full');
     AtDtDAd = AtDtDAd + we*colourconv2(weight_xx.*colourconv2(d,fliplr(flipud(dxxf)),'valid'),dxxf,'full');
     AtDtDAd = AtDtDAd + we*colourconv2(weight_yy.*colourconv2(d,fliplr(flipud(dyyf)),'valid'),dyyf,'full');
     AtDtDAd = AtDtDAd + we*colourconv2(weight_xy.*colourconv2(d,fliplr(flipud(dxyf)),'valid'),dxyf,'full');

     % step_length = rho / ( d(:)'*AtDtDAd(:) );
     step_length = rho ./ squeeze( sum(sum(d.*AtDtDAd,1),2) ); % vector of step lengths for each channel
     for c = 1:channels
         x(:,:,c) = x(:,:,c) + step_length(c) * d(:,:,c);                    % update approximation vector
         r(:,:,c) = r(:,:,c) - step_length(c) * AtDtDAd(:,:,c);                 % compute residual
     end

     rho_1 = rho;
     % rho = (r(:)'*r(:));
     rho = squeeze(sum(sum(r.^2,1),2));
     beta = rho ./ rho_1; % fletcher-reeves formula
     for c = 1:channels
         d(:,:,c) = r(:,:,c) + beta(c)*d(:,:,c); % update direction
     end
     fprintf('%d ',iter);
end
fprintf('\n');

