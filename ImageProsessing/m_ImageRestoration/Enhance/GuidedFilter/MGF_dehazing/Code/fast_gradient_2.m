function q = fast_gradient_2(I, p, N, N1)
%   GUIDEDFILTER   O(1) time implementation of guided filter.
%
%   - guidance image: I (should be a gray-scale/single channel image)
%   - filtering input image: p (should be a gray-scale/single channel image)
%   - regularization parameter: eps
eps = 0.04^2;

[h,w,~] = size(I);

s_start = [36 64];
s_end = [h w];

r = 16;

I_sub = imresize(I, s_start, 'nearest'); % NN is often enough
p_sub = imresize(p, s_start, 'nearest');
% r_sub = r / s; % make sure this is an integer
% [hei, wid] = size(I_sub);
% N = boxfilter(ones(hei, wid), r); % the size of each local patch; N=(2r+1)^2 except for boundary pixels.
 
mean_I = boxfilter(I_sub, r) ./ N;
mean_p = boxfilter(p_sub, r) ./ N;
mean_Ip = boxfilter(I_sub.*p_sub, r) ./ N;
cov_Ip = mean_Ip - mean_I .* mean_p; % this is the covariance of (I, p) in each local patch.
mean_II = boxfilter(I_sub.*I_sub, r) ./ N;
var_I = mean_II - mean_I.*mean_I;
 
%weight
epsilon=(0.01*(max(p_sub(:))-min(p_sub(:))))^2;
r1=4;
% N1 = boxfilter(ones(hei, wid), r1); % the size of each local patch; N=(2r+1)^2 except for boundary pixels.
mean_I1 = boxfilter(I_sub, r1) ./ N1;
mean_II1 = boxfilter(I_sub.*I_sub, r1) ./ N1;
var_I1 = mean_II1 - mean_I1.*mean_I1;
 
chi_I=sqrt(abs(var_I1.*var_I));    
weight=(chi_I+epsilon)/(mean(chi_I(:))+epsilon);     
 
gamma = (4/(mean(chi_I(:))- min(chi_I(:))))*(chi_I-mean(chi_I(:)));
gamma = 1 - 1./(1 + exp(gamma));
 
%result
a = (cov_Ip + (eps./weight).*gamma) ./ (var_I + (eps./weight)); 
b = mean_p - a .* mean_I; 
 
mean_a = boxfilter(a, r) ./ N;
mean_b = boxfilter(b, r) ./ N;
mean_a = imresize(mean_a, s_end, 'bilinear'); % bilinear is recommended
mean_b = imresize(mean_b, s_end, 'bilinear');
q = mean_a .* I + mean_b; 
end