function [u,k] = blind_LP_FW(f, MK, NK, lambda, params)
% M. Jin, S, Roth and P. Favaro: "Normalized Blind Deconvolution", 
% The European Conference on Computer Vision (ECCV), 2018. 
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

if ~exist('params','var')
    params.iters = 1000;
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

u = params.u;
k = params.k;
x_iter = params.x_iter;
k_iter = params.k_iter;
for  it = 1:params.iters
    % update sharp image
    [u, ~] = tvl2_LBFGS(f, k, lambda*norm(k(:),2), u, x_iter);
    % update blur
    k = FrankWolfe_Lp(u, k, f, k_iter, lambda, 2);
    % Kernel projection

    if params.visualize
        if mod(it,5)==0
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
            imagesc(([k params.k]));
            colormap gray(256)
            colorbar
            axis equal
            drawnow
        end
    end
end




