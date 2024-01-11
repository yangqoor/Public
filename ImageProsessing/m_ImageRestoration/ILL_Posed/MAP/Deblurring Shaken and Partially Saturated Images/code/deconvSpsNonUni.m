% [x]=deconvSpsNonUni(imblur,kernel,we,max_it,theta_s,K,saturation_mask,fit_grad_data)

% Derived from Sparse Deconvolution code by Levin et al.
%   see http://groups.csail.mit.edu/graphics/CodedAperture/ for more details
% Modification for non-uniform blur by Oliver Whyte, 2011

function [x]=deconvSpsNonUni(imblur,kernel,we,max_it,non_uniform,saturation_mask,theta_s,K,use_eff)
% if nargin < 8, saturation_mask = 1; end
%note: size(filt1) is expected to be odd in both dimensions 
% non_uniform = 1;
if ~exist('max_it','var'), max_it  =200; end
if ~exist('use_eff','var') || isempty(use_eff), use_eff = false; end
if ~exist('saturation_mask','var') || isempty(saturation_mask), saturation_mask = 1; end

[n,m,channels]=size(imblur);

if non_uniform
    % Remove zero kernel elements
    theta_s = theta_s(:,kernel~=0);
    kernel = kernel(kernel~=0);
    [pad, Kpadded] = calculatePadding([n,m],non_uniform,theta_s,K);
else
    if ((mod(size(kernel, 1), 2) ~= 1) | (mod(size(kernel, 2), 2) ~= 1))
      fprintf('Error - blur kernel must be odd-sized.\n');
      return;
    end;
    pad = calculatePadding([n,m],non_uniform,kernel);
end

m = m + pad(3) + pad(4);
n = n + pad(1) + pad(2);

dxf  = [1 -1];
dyf  = [1;-1];
dyyf = [-1; 2; -1];
dxxf = [-1, 2, -1];
dxyf = [-1 1;1 -1];

weight_x  = ones(n,m-1,channels);
weight_y  = ones(n-1,m,channels);
weight_xx = ones(n,m-2,channels);
weight_yy = ones(n-2,m,channels);
weight_xy = ones(n-1,m-1,channels);

if non_uniform
    x = deconvL2NonUni_w(imblur,kernel,we,max_it,weight_x,weight_y,weight_xx,weight_yy,weight_xy,non_uniform,saturation_mask,[],theta_s,K,use_eff);
else
    x = deconvL2NonUni_w(imblur,kernel,we,max_it,weight_x,weight_y,weight_xx,weight_yy,weight_xy,non_uniform,saturation_mask,[]);
end

w0    = 0.1;
exp_a = 0.8;
thr_e = 0.01; 

% Define a function to filter colour images using conv2
if channels==1
    colourconv2 = @(im,h,sz) conv2(im,h,sz);
else
    eval(['colourconv2 = @(im,h,sz) cat(3' sprintf(',conv2(im(:,:,%d),h,sz)',1:channels) ');']);
end

for t=1:2
    disp(sprintf('t = %d',t));
    dy  = colourconv2(x,fliplr(flipud(dyf)) ,'valid');
    dx  = colourconv2(x,fliplr(flipud(dxf)) ,'valid');
    dyy = colourconv2(x,fliplr(flipud(dyyf)),'valid');
    dxx = colourconv2(x,fliplr(flipud(dxxf)),'valid');
    dxy = colourconv2(x,fliplr(flipud(dxyf)),'valid');

    weight_x  =      w0*max(abs(dx) ,thr_e).^(exp_a-2); 
    weight_y  =      w0*max(abs(dy) ,thr_e).^(exp_a-2);
    weight_xx = 0.25*w0*max(abs(dxx),thr_e).^(exp_a-2); 
    weight_yy = 0.25*w0*max(abs(dyy),thr_e).^(exp_a-2);
    weight_xy = 0.25*w0*max(abs(dxy),thr_e).^(exp_a-2);
  
    if non_uniform
        x = deconvL2NonUni_w(imblur,kernel,we,max_it,weight_x,weight_y,weight_xx,weight_yy,weight_xy,non_uniform,saturation_mask,[],theta_s,K,use_eff);
    else
        x = deconvL2NonUni_w(imblur,kernel,we,max_it,weight_x,weight_y,weight_xx,weight_yy,weight_xy,non_uniform,saturation_mask,[]);
    end
end

x = padImage(x, -pad);

return


