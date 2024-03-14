function outImage = gdgif(guidImage, filtImage, r, lam)
%   Gradient Domain Guided Image Filtering   
%
%   - guidance image: guidImage (should be a gray-scale/single channel image)
%   - filtering input image: filtImage (should be a gray-scale/single channel image)
%   - local window radius: r
%   - regularization parameter: lam
%
%    References:
%      [2] Kaiming He, Jian Sun, Xiaou Tang, "Guided Image Filtering," IEEE
%       Transactions on Pattern Analysis and Machine Intelligence, Volume
%       35, Issue 6, pp. 1397-1409, June 2013.
%      [1] Fei Kou, Weihai Chen, Changyun Wen, and Zhengguo Li, "Gradient Domain 
%       Guided Image Filtering", IEEE Transactions on Image Processing, 
%       2015, 24(11):4528-4539.

outImage = zeros(size(filtImage));
if ~isa(guidImage,'uint8')
	guidImage = im2uint8(guidImage);
end
guidImage = double(guidImage);
if ~isa(filtImage,'uint8')
    filtImage = im2uint8(filtImage);
end
filtImage = double(filtImage);

if (size(guidImage, 3) == 3) && (size(filtImage, 3) == 3)
    for i = 1:3
        I = guidImage(:, :, i);
        p = filtImage(:, :, i);
        outImage(:, :, i) = filter_single_channel(I, p, r, lam);
    end
elseif (size(guidImage, 3) == 1) && (size(filtImage, 3) == 1)
    outImage = filter_single_channel(guidImage, filtImage, r, lam);
else
    error('Please check input images')
end
outImage = uint8(outImage);
end

function q = filter_single_channel(I, p, r, lam)
[hei, wid] = size(I);
N = boxfilter(ones(hei, wid), r); 
mean_I = boxfilter(I, r) ./ N;  
mean_p = boxfilter(p, r) ./ N;
mean_Ip = boxfilter(I.*p, r) ./ N;
cov_Ip = mean_Ip - mean_I .* mean_p; 
mean_II = boxfilter(I.*I, r) ./ N;
var_I = mean_II - mean_I .* mean_I;

L = 255;
delta = (0.001 * L)^2;
N_3 = boxfilter(ones(hei, wid), 1);
mean_II_3 = boxfilter(I.*I, 1) ./ N_3;
mean_I_3 = boxfilter(I, 1) ./ N_3;
var_I_3 = mean_II_3 - mean_I_3 .* mean_I_3;
Chi_I = sqrt(var_I_3) .* sqrt(var_I);
Gamma_I = (Chi_I + delta) .* (sum(sum(1 ./ (Chi_I + delta))) / (hei * wid)); % Eqn. (9) in the paper;
eta = 4 / (mean2(Chi_I) - min(min(Chi_I)));
gamma_I = 1 - 1 ./ (1 + exp(eta * (Chi_I - mean2(Chi_I)))); % Eqn. (11) in the paper;

a = (cov_Ip + (lam ./ Gamma_I) .* gamma_I) ./ (var_I + (lam ./ Gamma_I)); % Eqn. (12) in the paper;
b = mean_p - a .* mean_I; % Eqn. (13) in the paper;
mean_a = boxfilter(a, r) ./ N;
mean_b = boxfilter(b, r) ./ N;
q = mean_a .* I + mean_b; % Eqn. (14) in the paper;
end

