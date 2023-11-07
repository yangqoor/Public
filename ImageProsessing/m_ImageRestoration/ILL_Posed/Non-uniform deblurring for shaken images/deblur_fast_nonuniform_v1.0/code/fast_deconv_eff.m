% fast_deconv_eff uses the EFF weights to extract the patches, deblurs each patch independently,
%   before finding the sharp image that best matches the patches
function [yout] = fast_deconv_eff(yin, kernel, lambda, alpha, non_uniform, theta_list, Kblur, yout0)
%
%
% fast_deconv solves the deconvolution problem in the paper (see Equation (1))
% D. Krishnan, R. Fergus: "Fast Image Deconvolution using Hyper-Laplacian
% Priors", Proceedings of NIPS 2009.
%
% This paper and the code are related to the work and code of Wang
% et. al.:
%
% Y. Wang, J. Yang, W. Yin and Y. Zhang, "A New Alternating Minimization
% Algorithm for Total Variation Image Reconstruction", SIAM Journal on
% Imaging Sciences, 1(3): 248:272, 2008.
% and their FTVd code. 
  
% Input Parameters:
%
% yin: Observed blurry and noisy input grayscale image.
% kernel:  convolution kernel
% theta_list: 3 x K matrix of camera orientations for each kernel element
% Kblur: internal calibration matrix of camera
% lambda: parameter that balances likelihood and prior term weighting
% alpha: parameter between 0 and 2
% yout0: if this is passed in, it is used as an initialization for the
% output deblurred image; if not passed in, then the input blurry image
% is used as the initialization
%
%
% Outputs:
% yout: solution
% 
% Note: for faster LUT interpolation, please download and install
% matlabPyrTools of Eero Simoncelli from
% www.cns.nyu.edu/~lcv/software.php. The specific MeX function required
% is pointOp (used in solve_image.m).
%
% Copyright (C) 2009. Dilip Krishnan and Rob Fergus
% Email: dilip,fergus@cs.nyu.edu

% Modification for non-uniform blur by Oliver Whyte, 2011

sequential = true;

% continuation parameters
beta = 1;
beta_rate = 2*sqrt(2);
beta_max = 2^8;

oldweights = 0;
if oldweights
    weightsextract = 'deblur';
    weightscombine = 'deblur';
else
    weightsextract = 'sharp';
    weightscombine = 'deblurnew';
end

% number of inner iterations per outer iteration
mit_inn = 1;

[m n channels] = size(yin); 

% Rescale image brightness to get better behaviour
scale = 0.3 / median(yin(:));
yin = scale * yin;
if exist('yout0','var') && ~isempty(yout0)
    yout0 = scale * yout0;
end

if non_uniform
    theta_list = theta_list(:,kernel~=0);
    kernel = kernel(kernel~=0);
end

kernel = kernel/sum(kernel(:));

if ~exist('grid_size','var') || isempty(grid_size)
    if non_uniform
        grid_size = [6 8]; 
    else
        grid_size = [1 1];
    end
end

if non_uniform
    [pad_replicate, Kblur] = calculatePadding(size(yin),non_uniform,theta_list,Kblur);
else
    pad_replicate = calculatePadding(size(yin),non_uniform,kernel);
end

yin = padImage(yin, pad_replicate, 'replicate');

if non_uniform
    eff = makeEFF(size(yin), theta_list, grid_size, Kblur);
else
    eff = makeEFF(size(yin), kernel, grid_size);
end

yin = padImage(yin, eff.pad, 'replicate');

[m n channels] = size(yin); 

if sequential
    % Anonymous functions to retrieve filters and patches
    kernel_fft = @(p) computeFilterStackEFF(eff, kernel, 1, p);
    yin_fft = @(p) computeImageStackEFF(eff, yin, weightsextract, 1, p);
else
    % Make stacks of patches
    kernel_fft = computeFilterStackEFF(eff, kernel, 1);
    yin_fft = computeImageStackEFF(eff, yin, weightsextract, 1);
end

% initialize with input or passed in initialization
if ~exist('yout0','var') || isempty(yout0)
    yout = yin;
else
    yout0 = padImage(yout0, pad_replicate, 'replicate');
    yout = padImage(yout0, eff.pad, 0);
end

pm = 2*eff.patch_size(1);
pn = 2*eff.patch_size(2);
n_grid = prod(eff.grid_size);

% compute constant quantities
% see Eqn. (3) of paper
if sequential
    % Anonymous functions to retrieve filters and patches
    Nomin1 = @(yin_fft_patch,kernel_fft_patch) bsxfun(@times, yin_fft_patch, conj(kernel_fft_patch));
    Denom1 = @(kernel_fft_patch) abs(kernel_fft_patch).^2;
else
    Nomin1 = bsxfun(@times, yin_fft, conj(kernel_fft));
    Denom1 = abs(kernel_fft).^2;
end
Denom2 = abs(psf2otf([1,-1],2*eff.patch_size)).^2 + abs(psf2otf([1;-1],2*eff.patch_size)).^2;
% [Nomin1, Denom1, Denom2] = computeDenominator(yin, kernel);

% x and y gradients of yout (with circular boundary conditions)
% other gradient filters may be used here and their transpose will then need to
% be used within the inner loop (see comment below) and in the function
% computeDenominator
youtx = [diff(yout, 1, 2), yout(:,1,:,:) - yout(:,pn,:,:)]; 
youty = [diff(yout, 1, 1); yout(1,:,:,:) - yout(pm,:,:,:)]; 

% store some of the statistics
costfun = [];
Outiter = 0;

%% Main loop
while beta <= beta_max
    Outiter = Outiter + 1; 
    fprintf('Outer iteration %d; beta %.3g\n',Outiter, beta);
    
    gamma = beta/lambda;
    if sequential
        Denom = @(Denom1) bsxfun(@plus, Denom1, gamma*Denom2);
    else
        Denom = bsxfun(@plus, Denom1, gamma*Denom2);
    end
    Inniter = 0;

    for Inniter = 1:mit_inn
      % 
      % w-subproblem: eqn (5) of paper
      % 
      Wx = solve_image(youtx, beta, alpha);
      Wy = solve_image(youty, beta, alpha);
      if sequential
          yout = [];
          for gi=1:n_grid
              Wx_patch = computeImageStackEFF(eff, Wx, weightsextract, 0, gi);
              Wy_patch = computeImageStackEFF(eff, Wy, weightsextract, 0, gi);
              % 
              %   x-subproblem: eqn (3) of paper
              % 
              % The transpose of x and y gradients; if other gradient filters
              % (such as higher-order filters) are to be used, then add them
              % below the comment above as well
              Wxx = [Wx_patch(:,pn,:,:) - Wx_patch(:,1,:,:), -diff(Wx_patch,1,2)]; 
              Wxx = Wxx + [Wy_patch(pm,:,:,:) - Wy_patch(1,:,:,:); -diff(Wy_patch,1,1)]; 
              yin_fft_patch = yin_fft(gi);
              kernel_fft_patch = kernel_fft(gi);
              Nomin = bsxfun(@plus, Nomin1(yin_fft_patch,kernel_fft_patch), gamma*fft2(Wxx));
              D1 = Denom1(kernel_fft_patch);
              yout_fft = bsxfun(@rdivide, Nomin, Denom(D1)); 
              yout = recombineImageStackEFF(eff, yout_fft, weightscombine, 1, yout, gi);
          end
          yout = recombineImageStackEFF(eff, [], weightscombine, 1, yout);
      else
          Wx = computeImageStackEFF(eff, Wx, weightsextract, 0);
          Wy = computeImageStackEFF(eff, Wy, weightsextract, 0);
          % 
          %   x-subproblem: eqn (3) of paper
          % 
          % The transpose of x and y gradients; if other gradient filters
          % (such as higher-order filters) are to be used, then add them
          % below the comment above as well
          Wxx = [Wx(:,pn,:,:) - Wx(:,1,:,:), -diff(Wx,1,2)]; 
          Wxx = Wxx + [Wy(pm,:,:,:) - Wy(1,:,:,:); -diff(Wy,1,1)]; 
          Nomin = bsxfun(@plus, Nomin1, gamma*fft2(Wxx));
          yout_fft = bsxfun(@rdivide, Nomin, Denom); 
          yout = recombineImageStackEFF(eff, yout_fft, weightscombine, 1);
      end
      
      % update the gradient terms with new solution
      youtx = [diff(yout, 1, 2), yout(:,1,:,:) - yout(:,pn,:,:)]; 
      youty = [diff(yout, 1, 1); yout(1,:,:,:) - yout(pm,:,:,:)]; 

    end %inner
    beta = beta*beta_rate;
end %Outer

yout = padImage(yout, -eff.pad-pad_replicate);

yout = yout / scale;