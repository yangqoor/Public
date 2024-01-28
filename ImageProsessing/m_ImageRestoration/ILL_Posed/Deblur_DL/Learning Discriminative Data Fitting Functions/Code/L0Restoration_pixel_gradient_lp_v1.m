function S = L0Restoration_pixel_gradient_lp_v1(Im, kernel, lambda, wei_grad, g_residual, weights, filters, kappa)
%%
% Image restoration with L0 prior
% The objective function: 
% S^* = argmin ||I*k - B||^2 + lambda |\nabla I|_0
%% Input:
% @Im: Blurred image
% @kernel: blur kernel
% @lambda: weight for the L0 prior
% @kappa: Update ratio in the ADM
%% Output:
% @S: Latent image
%
% The Code is created based on the method described in the following paper 
%   [1] Jinshan Pan, Zhe Hu, Zhixun Su, and Ming-Hsuan Yang,
%        Deblurring Text Images via L0-Regularized Intensity and Gradient
%        Prior, CVPR, 2014. 
%   [2] Li Xu, Cewu Lu, Yi Xu, and Jiaya Jia. Image smoothing via l0 gradient minimization.
%        ACM Trans. Graph., 30(6):174, 2011.
%
%   Author: Jinshan Pan (sdluran@gmail.com)
%   Date  : 05/18/2014

if ~exist('kappa','var')
    kappa = 2.0;
end
%% pad image
H = size(Im,1);    W = size(Im,2);
Im = wrap_boundary_liu(Im, opt_fft_size([H W]+size(kernel)-1));
for ii = 1:length(filters)+1
    tmp = zeros(size(Im));
    tmp(1:H, 1:W, :) = g_residual{ii};
    g_residual{ii} = tmp;
end
%%
S = Im;
betamax = 1e5;
fx = [1, -1];
fy = [1; -1];
% [N,M,D] = size(Im);
% sizeI2D = [N,M];
%% for filters
[N,M,D] = size(Im);
sizeI2D = [N,M];
otfFx = psf2otf(fx,sizeI2D);
otfFy = psf2otf(fy,sizeI2D);
otf_filters = cell(length(filters),1);
for ii = 1:length(filters)
    otf_filters{ii} = psf2otf(filters{ii},sizeI2D);
end
%%
KER = psf2otf(kernel,sizeI2D);
Den_KER = abs(KER).^2;
%%
%Den_KER_modify = zeros(size(Den_KER));
Den_KER_modify = (weights(1) + 1)*Den_KER;
for ii = 1:length(filters)
    %Den_KER_modify = Den_KER_modify + weights(ii + 1)*(conj(otf_filters{ii}).*Den_KER.*otf_filters{ii});
    %Den_KER_modify = Den_KER_modify + weights(ii + 1)*(abs(otf_filters{ii}.*KER).^2);
    Den_KER_modify = Den_KER_modify + weights(ii + 1)*(conj(KER).*conj(otf_filters{ii}).*otf_filters{ii}.*KER);
end
%%
Denormin2 = abs(otfFx).^2 + abs(otfFy ).^2;
% Denormin2 = 0;
% for ii = 1:length(filters)
%     Denormin2 = Denormin2 + weights(ii + 1)*(abs(otf_filters{ii}).^2);
% end
if D>1
    Denormin2 = repmat(Denormin2,[1,1,D]);
    KER = repmat(KER,[1,1,D]);
    Den_KER_modify = repmat(Den_KER_modify,[1,1,D]);
    for ii = 1:length(filters)
        otf_filters{ii} = repmat(otf_filters{ii},[1,1,D]);
    end
end
%Normin1 = conj(KER).*fft2(S);
%% For normininator
Normin1 = (weights(1) + 1)*(conj(KER).*fft2(S)) + (weights(1) + 1)*(conj(KER).*fft2(g_residual{1}));
for ii = 1:length(filters)
    Normin1 = Normin1 + weights(ii + 1)*(conj(otf_filters{ii}).*conj(KER).*otf_filters{ii}.*fft2(S)) ... 
        + weights(ii + 1)*(conj(otf_filters{ii}).*conj(KER).*fft2(g_residual{ii + 1}));
    %Normin1 = Normin1 + weights(ii + 1)*(conj(KER).*(abs(otf_filters{ii}).^2).*fft2(S));
end
%%
%% pixel sub-problem
mybeta_pixel = lambda/(graythresh((S).^2));
%mybeta_pixel = 2*lambda;
%%
%mybeta_pixel = 0.01;
maxbeta_pixel = 2^3;
while mybeta_pixel< maxbeta_pixel
    %% pixel l0-norm i.e., (u-S).^2 + lambda/mybeta_pixel*\|u\|_0
    u = S;
    if D==1
        t = u.^2<lambda/mybeta_pixel;
    else
        t = sum(u.^2,3)<lambda/mybeta_pixel;
        t = repmat(t,[1,1,D]);
    end
    u(t) = 0;
    clear t;
    %% Gradient sub-problem
    beta = 2*wei_grad;
    %beta = 0.01;
    while beta < betamax
        Denormin   = Den_KER_modify + beta*Denormin2 + mybeta_pixel;
        % h-v subproblem
        h = [diff(S,1,2), S(:,1,:) - S(:,end,:)];
        v = [diff(S,1,1); S(1,:,:) - S(end,:,:)];
        if D==1
            t = (h.^2+v.^2)<wei_grad/beta;
        else
            t = sum((h.^2+v.^2),3)<wei_grad/beta;
            t = repmat(t,[1,1,D]);
        end
        h(t)=0; v(t)=0;
        clear t;
        % S subproblem
        Normin2 = [h(:,end,:) - h(:, 1,:), -diff(h,1,2)];
        Normin2 = Normin2 + [v(end,:,:) - v(1, :,:); -diff(v,1,1)];
        %Normin2 = u;%% for pixel
        FS = (Normin1 + beta*fft2(Normin2) + mybeta_pixel*fft2(u))./Denormin;
        
        %FS = (1-idx_maxpixel).*FS2 + idx_maxpixel.*FS1;
        S = real(ifft2(FS));
        beta = beta*kappa;
        if wei_grad==0
            break;
        end
    end
    mybeta_pixel = mybeta_pixel*kappa;
end
S = S(1:H, 1:W, :);
end