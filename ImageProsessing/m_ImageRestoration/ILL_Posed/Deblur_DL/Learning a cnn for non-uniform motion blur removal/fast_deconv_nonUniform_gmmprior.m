function [yout] = fast_deconv_nonUniform_gmmprior(yin, yout0, kernels, params, kernelInit)
%
%
% Fast non-blind deconvolution for non-uniform deblurring. Written based on
% R.Fergus's codes by Jian SUN (XJTU)
%
%
% Input Parameters:
%
% yin: Observed blurry and noisy input grayscale image.
% k:  convolution kernel
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
%
% Email: jiansun@mail.xjtu.edu.cn

addpath('./epllcode');
% load GMM model
load GSModel_8x8_200_2M_noDC_zeromean.mat
patchSize = 8;


% initialize prior function handle
excludeList = [];
prior = @(Z,patchSize,noiseSD,imsize) aprxMAPGMM(Z,patchSize,noiseSD,imsize,GS,excludeList);

if size(yin, 3) == 3
    yin_orig = yin;
%    yin = double(rgb2gray(yin));
    yout0 = yin;
end

mlhmag = kernelInit.mlhmag;
mlhori = kernelInit.mlhori;

% load parameters
lambda = 1.5e+5;
maxIter_out = params.maxIter_out; %10;
maxIter_in = params.maxIter_in;

if(0)

    [d, r,c] = size(kernels.kernels_prob);
    mlhmag = zeros(r,c);
    mlhori = zeros(r,c);

    est_map2 = reshape(kernels.kernels_prob, d, []);
    [vals,ords]=sort(est_map2, 1, 'descend');
    est_map_top = reshape(vals(1 : 1, :), [r, c]);
    ors_map_top = reshape(ords(1 : 1, :), [r, c]);

    ids = find(ors_map_top >= 1);
    est_map_valid = est_map_top(ids);
    ors_map_valid = ors_map_top(ids);

    ks = kernels.motionkernelID(:, ors_map_valid);
    mlhmag(ids) = ks(2,:);
    mlhori(ids) = ks(1,:);
end

us = mlhmag .* cos(mlhori / 180 * pi);
vs = mlhmag .* sin(mlhori / 180 * pi);
%figure, subplot(1,4,1); imagesc(us);
%subplot(1,4,2), imagesc(vs);


% continuation parameters
beta_rate = 4;
beta_max = 2^16;
[m n d] = size(yin); 

% initialize with input or passed in initialization
if (nargin == 5)
  yout = yout0;
else
  yout = yin; 
end;

bmu = us; % initialized motion field in x direction
bmv = vs; % initialized motion field in y direction

%params.lambda = 1e-4;
%%params.beta = 1;
%params.mu = 0;
%params.gamma = 1e-3; %4e-4;
%params.alpha = 4/5;

%% Main loop
Outiter = 1;

tic;
bmu_nor = bmu; bmv_nor = bmv;
idSet_noblur = find((bmu == 1 & bmv == 0));
%bmu_nor(idSet) = sqrt(1/2);
%bmv_nor(idSet) = sqrt(1/2);
mag = sqrt((bmu.^2 + bmv.^2));
mag(find(mag == 0)) = 1;
bmu_nor = bmu ./ mag;
bmv_nor = bmv ./ mag;
betas = 50*[1 2 4 8 16 32 64];
beta = betas(1);
while beta < beta_max & Outiter <= params.maxIter_out
    %% update the gradients
   [bmag, bori] = motion2magori(bmu, bmv);   
   for c = 1 : d %params.maxIter_out
        yout = yin_orig(:,:,c);
        yin = yin_orig(:,:,c);
        by = motionBlurConv_mirror(double(yin), bmag, bori); % ??? to be updated
        for k = 1 : min(params.maxIter_in, length(betas))
          %Outiter = Outiter + 1;
          beta = betas(k); 
          fprintf('\n Outer iteration %d; Inner iteration %d for optimization of sharp image; beta %.3g\n',Outiter, k, beta);

          % z-subproblem
          Z = im2col(yout,[patchSize patchSize]);
          cleanZ = prior(Z,patchSize,(beta)^-0.5,size(yin));
      
          % x-subproblem
          [I1,counts] = scol2im(cleanZ,patchSize,size(yin,1),size(yin,2),'sum');
          b = lambda * by + beta * I1;
          yout = bicg(@(x,tflag) Afun_gmm(x,bmag, bori, counts, beta, lambda, tflag),b(:),1e-5,300,[],[],yout(:));
          yout = max(min(yout, 1), 0);
          yout = reshape(yout, m, n);

          % y = Afun_gmm(x,bmag, bori,counts,beta,lambda,transp_flag)
          % figure, imshow(uint8(yout * 255))
          if k == 8
              k
          end
        end
        yout_color(:, :, c) = yout;
   end
   
   yout = yout_color;
   
    %% Refine the blur kernels given current sharp image
    %% optimize by half-quadratic splitting
    if(0)
        beta = 0.02 * lambda;
        for k = 1 : maxIter_in
          %Outiter = Outiter + 1; 
          fprintf('Outer iteration %d; Inner iteration %d for optimization of blur kernel; beta %.3g\n',Outiter, k, beta);

          % w-subproblem
          bmu_dx = [diff(bmu, 1, 2), bmu(:,1) - bmu(:,n)]; 
          bmu_dy = [diff(bmu, 1, 1); bmu(1,:) - bmu(m,:)]; 
          bmv_dx = [diff(bmv, 1, 2), bmv(:,1) - bmv(:,n)]; 
          bmv_dy = [diff(bmv, 1, 1); bmv(1,:) - bmv(m,:)]; 

          wux = softThresh(bmu_dx, lambda / beta); 
          wuy = softThresh(bmu_dy, lambda / beta);
          wvx = softThresh(bmv_dx, lambda / beta); 
          wvy = softThresh(bmv_dy, lambda / beta);

          %wux = solve_image(bmu_dx, lambda / beta, alpha); 
          %wuy = solve_image(bmu_dy, lambda / beta, alpha);
          %wvx = solve_image(bmv_dx, lambda / beta, alpha); 
          %wvy = solve_image(bmv_dy, lambda / beta, alpha);

          % sub-problem for optimization of motion field: optimize by L-BFGS algorithm
          options.Method = 'lbfgs';
          options.MaxIter = 50;
          in = [bmu, bmv];
          params.beta = beta;
          out = minFunc(@motionFuncGrad_kernel,in(:), options, yout, yin, kernels, wux, wuy, wvx, wvy, params); 
          out = reshape(out, m, []);
          yout = reshape(yout, m, n);
          bmu = out(:, 1 : size(out, 2) / 2);
          bmv = out(:, size(out, 2)/ 2 + 1 : end);

          beta = beta*beta_rate;
        end
    end
    
    Outiter = Outiter + 1;
    if(0)
        figure, subplot(1,3,1), imagesc(bmu);
        subplot(1,3,2), imagesc(bmv);
    %   colormap(color);
        subplot(1,3,3), imshow(uint8(yout * 255));
    end
    log_res{Outiter}.bmu = bmu;
    log_res{Outiter}.bmv = bmv;
    log_res{Outiter}.yout = yout;
    %pause;
      
end %Outer
toc
Outiter;

%save('res.mat', 'log_res');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Nomin1, Denom1, Denom2] = computeDenominator(y, k)
%
% computes denominator and part of the numerator for Equation (3) of the
% paper
%
% Inputs: 
%  y: blurry and noisy input
%  k: convolution kernel  
% 
% Outputs:
%      Nomin1  -- F(K)'*F(y)
%      Denom1  -- |F(K)|.^2
%      Denom2  -- |F(D^1)|.^2 + |F(D^2)|.^2
%

sizey = size(y);
otfk  = psf2otf(k, sizey); 
Nomin1 = conj(otfk).*fft2(y);
Denom1 = abs(otfk).^2; 
% if higher-order filters are used, they must be added here too
Denom2 = abs(psf2otf([1,-1],sizey)).^2 + abs(psf2otf([1;-1],sizey)).^2;