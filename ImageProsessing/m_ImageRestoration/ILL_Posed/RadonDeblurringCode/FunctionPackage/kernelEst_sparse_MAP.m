% Kernel estimation function
% P = Projected radon transforms, kxm matrix, k : length of the projection vector,
%                                             m : number of projections
% K = Initial kernel estimate
% ang = orientation of each projection
% stdnoise = noise std
% filts = filters for regularization
function I = kernelEst_sparse_MAP...
    (xMap, B, P,K,ang,stdnoise,stdnoiseB,filts, a, numSampOrientation, edgeMask, weightObs)

% % hyper laplacian exponent
%weightObs = 1000;

[xh, xw, xz] = size(xMap);

[h, w] = size(K);
hh = round((h+1)/2);
hw = round((w+1)/2);

%%
edgeValid = find(edgeMask == 1);

%% Computing constants for the linear program
xBTT = flipud(im2col(xMap, [h, w], 'sliding'));
xBT = xBTT(:, edgeValid);

BC = B(hh:end-hh+1, hw:end-hw+1);
BC = BC(edgeValid);
bTT = weightObs*xBT*BC/(length(edgeValid)*stdnoiseB^2);
xBTxB = weightObs*xBT*xBT'/(length(edgeValid));

% compute R'P, which is equivalent to back-projection
bT=0;
for l = 1:length(ang)
    bT = bT + numSampOrientation(l)*iradon([P(:, l), P(:, l)], [ang(l), ang(l)],'linear', 'none', 1, h);
end
bT = bT/sum(numSampOrientation); 
% b = iradon(PW, ang,'linear', 'none', 1, h);
bT = bT(:)/stdnoise^2;
b = bT + bTT;
 
% do deblurring
I = kernelEst_opt_MAP(b,xBTxB,K,ang,stdnoise,stdnoiseB,filts, numSampOrientation);

iters = 13;

global display_iterations; 

if (display_iterations)
    figure(1);
    imshowc(I); 
end

min_err = 0.003;

%% reweighted least squares
for i=1:iters
   
    % compute weights
    filts = compute_filter_weights_kernelEst(I,filts,a);    
    I = kernelEst_opt_MAP(b,xBTxB, I,ang,stdnoise,stdnoiseB,filts, numSampOrientation); 
    
    if (display_iterations)
        figure(1);
        imshowc(I); 
    end 
    
end

% I = max(min(I,1),0);
