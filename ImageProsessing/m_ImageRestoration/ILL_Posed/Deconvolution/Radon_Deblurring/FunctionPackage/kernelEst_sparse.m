% Kernel estimation function
% P = Projected radon transforms, kxm matrix, k : length of the projection vector,
%                                             m : number of projections
% K = Initial kernel estimate
% ang = orientation of each projection
% stdnoise = noise std
% filts = filters for regularization
function I = kernelEst_sparse(P,K,ang,stdnoise,filts, a, numSampOrientation)

% % hyper laplacian exponent
% a = 0.5;

[h, w] = size(K);

% do deblurring
I = kernelEst_opt(P,K,ang,stdnoise,filts, numSampOrientation);

iters = 13;

min_err = 0.003;

%% reweighted least squares
for i=1:iters
   
    % compute weights
    filts = compute_filter_weights_kernelEst(I,filts,a);    
    I = kernelEst_opt(P,I,ang,stdnoise,filts, numSampOrientation); 

    figure(1);
    imshowc(I);    
end

I = max(min(I,1),0);
