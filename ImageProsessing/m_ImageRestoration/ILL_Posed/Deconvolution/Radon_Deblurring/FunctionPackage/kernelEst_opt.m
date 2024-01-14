function img = kernelEst_opt(P, K, ang, stdnoise,filts, numSampOrientation)

% display stuff
global display_iterations;
global print_iters;

if (isempty(display_iterations))
    display_iterations = 0;
end

if (isempty(print_iters))
    print_iters = 0;
end

[h, w] = size(K);

maxiters = 25;

% compute R'P, which is equivalent to back-projection
bT=0;
for l = 1:length(ang)
    bT = bT + numSampOrientation(l)*iradon([P(:, l), P(:, l)], [ang(l), ang(l)],'linear', 'none', 1, h);
end
bT = bT/sum(numSampOrientation); 
% b = iradon(PW, ang,'linear', 'none', 1, h);
b = bT(:)/stdnoise^2;

% conjugate gradient
x = minres(@compute_Ax_kernelEst,b(:),1e-4,maxiters,[],[],K(:),ang, stdnoise,filts, h, w, numSampOrientation);

x = reshape(x,[h,w]);

img = x;
img = max(min(img,1),0);
img = img/sum(img(:)); 

function Ax = compute_Ax_kernelEst(K,ang, stdnoise,filts, h, w, numSampOrientation)

K = reshape(K, [h, w]);
fprintf('.');

% First projection
[h, w] = size(K);

RK = radon(K, ang);
RtRK=0;
for l = 1:length(ang)
    RtRK = RtRK + numSampOrientation(l)*iradon([RK(:, l), RK(:, l)], [ang(l), ang(l)],'linear', 'none', 1, h);
end
RtRK = RtRK/sum(numSampOrientation);

% RtRK = iradon(RK, ang, 'linear', 'none', 1, h); 
RtRK = RtRK(:)/stdnoise^2;

% filter responces
Afilter = filter_responces_for_cg_kernelEst(K,filts);

Ax = RtRK + 2*Afilter(:);