%
%   Code for
%   Zongwei Lu, Bangyuan Long, Kang Li and Fajin Lu, "Effective Guided Image Filtering for Contrast Enhancement", IEEE Signal Processing Letters, vol.25, no.10, pp.1585-1589, Oct,2018.
%

%   Code Author: Zongwei Lu
%   Email: luzongwei@hotmail.com;bangyuanl@hotmail.com
%   Date: 8/28/2018

%   Modified from the code provied by Dr. Kaiming He et. al. for their paper
%   "Guided Image Filtering", by Kaiming He, Jian Sun, and Xiaoou Tang, in ECCV 2010
%   The code and the algorithm are for non-comercial use only.

%   - guidance image: I (should be a gray-scale/single channel image)
%   - filtering input image: p (should be a gray-scale/single channel image)
%   - local window radius: r
%   - regularization parameter: eps

function [q, beta] = egif(I, p, r, eps)

    eps0 = (0.001) ^ 2;

    [hei, wid] = size(I);
    N = boxfilter(ones(hei, wid), r); % the size of each local patch; N=(2r+1)^2 except for boundary pixels.

    mean_I = boxfilter(I, r) ./ N;
    mean_p = boxfilter(p, r) ./ N;
    mean_Ip = boxfilter(I .* p, r) ./ N;
    cov_Ip = mean_Ip - mean_I .* mean_p; % this is the covariance of (I, p) in each local patch.

    mean_II = boxfilter(I .* I, r) ./ N;
    var_II = mean_II - mean_I .* mean_I;

    a = cov_Ip ./ (var_II + (eps .* mean2(var_II)) + eps0); % eqn.(13)
    b = mean_p - a .* mean_I;

    mean_a = boxfilter(a, r) ./ N;
    mean_b = boxfilter(b, r) ./ N;

    gamma = 1.0;
    beta = ((mean_a ./ (1 - mean_a))) .^ gamma; % eqn.(27)

    q = mean_a .* I + mean_b;

end
