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
%%
% Modified by Dong Gong @2016
%%

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

us = mlhmag .* cos(mlhori / 180 * pi);
vs = mlhmag .* sin(mlhori / 180 * pi);

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

bmu = us;
bmv = vs;

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
            fprintf('OuterIte=%d, InnerIte=%d/%d\n', Outiter, k, min(params.maxIter_in, length(betas)));
            
            % z-subproblem
            Z = im2col(yout,[patchSize patchSize]);
            cleanZ = prior(Z,patchSize,(beta)^-0.5,size(yin));
            
            % x-subproblem
            [I1,counts] = scol2im(cleanZ,patchSize,size(yin,1),size(yin,2),'sum');
            b = lambda * by + beta * I1;
            yout = bicg(@(x,tflag) Afun_gmm(x,bmag, bori, counts, beta, lambda, tflag),b(:),1e-5,300,[],[],yout(:));
            yout = max(min(yout, 1), 0);
            yout = reshape(yout, m, n);
        end
        yout_color(:, :, c) = yout;
    end
    
    yout = yout_color;
    
    
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