function [u,k] = blind_LP(f, MK, NK, lambda, params)
% [u, k] = blind_LP(f, MK, NK, lambda, params) implements the blind
% deconvolution gradient decent algorithm presented in the paper:
%
% M. Jin, S, Roth and P. Favaro: "Normalized Blind Deconvolution", 
%  European Conference on Computer Vision (ECCV), 2018.
%
% Where f is the input blurry image, MK and NK are the support of
% the unknown PSF, and lambda weights the total variation
% regularization. In output the function gives the sharp image u
% and the PSF k.
% This function should not be used directly. It should be used in a
% pyramid scheme or in any scheme where the parameter lambda is
% carefully reduced at each call.
%
% [u, k] = deblur(f, MK, NK, lambda, params) allows the user to
% specify in the struct params additional input parameters, as:
%
% params.u:: [(f)]
%        Initial sharp image.
%
% params.k:: [(ones(MK,NK)/MK/NK)]
%        Initial PSF.
%
% params.iters:: [uint(1000)]
%        Number of innermost iterations for the gradient descent
%        algorithm.
%
% params.visualize:: [0-1]
%        If set to 1 visualize diagnostics and current estimates.
%
% Authors: Daniele Perrone, perrone@iam.unibe.ch
%          Paolo Favaro, paolo.favaro@iam.unibe.ch
% Copyright (C) 2014 Daniele Perrone and Paolo Favaro.  All rights
% reserved.

% get image dimension
[M, N, C] = size(f);
P = params.P;
if ~exist('params','var')
    params.iters = 500;
    params.u = padarray(f,[floor(MK/2) floor(NK/2)],'replicate');
    params.k = ones(MK,NK)/MK/NK;
    params.visualize = 0;
else
    if ~isfield(params,'iters')
        params.iters = 1000;
    end
    if ~isfield(params,'u')
        params.u = padarray(f,[floor(MK/2) floor(NK/2)],'replicate');
    end
    if ~isfield(params,'k')
        params.k = ones(MK,NK)/MK/NK;
    end
    if ~isfield(params,'visualize')
        params.visualize = 0;
    end
end

if ~exist('lambda','var')
    lambda = 0.016;
end
% size of sharp image
MU = M + MK - 1;
NU = N + NK - 1;
gradudata = zeros(MU,NU,C);
u = params.u;
k = params.k;
for  it = 1:params.iters
    % update sharp image
    % if conv2dFFTW_mex function does not work on your machine, then
    % replace it with conv2. conv2dFFTW_mex is a fast implementation of
    % conv2
    for c=1:C
        if numel(k)>41^2
            gradudata(:,:,c) = conv2dFFTW_mex(conv2dFFTW_mex(u(:,:,c) , k, 'valid') - f(:,:,c),...
                rot90(k,2), 'full');
        else
            gradudata(:,:,c) = conv2dFFTW_mex(conv2dFFTW_mex(u(:,:,c), k, 'valid') - f(:,:,c),...
                rot90(k,2), 'full');
        end
    end
    
    gradu = (gradudata - lambda*norm(k(:),P)*gradTVcc(u));
    sf = 5e-3*max(u(:))/max(1e-31,max(max(abs(gradu(:)))));
    u   = u - sf*gradu;
    
    % update blur
    gradk  = zeros(MK,NK);
    
    for c=1:C
        TV_energy = getTVEnergy(u(:,:,c));
        if numel(k)>41^2
            err = conv2dFFTW_mex(u(:,:,c), k,'valid') - f(:,:,c);
            gradk = conv2dFFTW_mex(rot90(u(:,:,c), 2), err, 'valid') + lambda*TV_energy.*abs(k).^(P-1)/(norm(k(:),P))^(P-1);
            
        else
            err = conv2dFFTW_mex(u(:,:,c), k,'valid') - f(:,:,c);
            gradk = conv2dFFTW_mex(rot90(u(:,:,c), 2), err, 'valid') + lambda*TV_energy.*abs(k).^(P-1)/(norm(k(:),P))^(P-1);
        end
    end
    
    sh = 1e-3*max(k(:))/max(1e-31,max(max(abs(gradk))));
    k = k - sh*gradk;
    
    % Kernel projection
    k = k.*(k>0);
    k = k/sum(k(:));
    
    if params.visualize
        if mod(it,200)==0
            fprintf('pruning isolated noise in kernel...\n');
            CC = bwconncomp(k,8);
            for ii=1:CC.NumObjects
                currsum=sum(k(CC.PixelIdxList{ii}));
                if currsum<.1
                    k(CC.PixelIdxList{ii}) = 0;
                end
            end
            k(k<0) = 0;
            k=k/sum(k(:));
            figure(1);
            uv = u;
            uv(uv > 1) = 1;
            uv(uv <0 ) = 0;
            fv=  f;
            fv(fv > 1) = 1;
            fv(fv < 0) = 0;
            fv = padarray(fv,[floor(MK/2) floor(NK/2)]);
            imagesc([uv fv]);
            colormap gray(256)
            drawnow
            
            figure(2)
            subplot(111)
            imagesc(k),colorbar;
            colormap gray(256)
            drawnow
        end
    end
end





