function [fm, fmm, fml, we] = wavefeat(file, nlevels, LoF, HiF)
% WAVEFEAT Wavelet-based feature extraction from texture image 小波纹理特征提取
%
% Input:
%	file: 	filename of the input texture image OR a matrix
%		Support all formats by imread
%	nlevels: number of wavelet decomposition levels
%	LoF, HiF: Decomposition filters
%
% Output:
%	fm:	feature vectors based on mean and standard deviation
%		of the magnitute of the wavelet coefficients
%	fmm: 	feature vectors based on generalized Gaussian pdf parameters
%		(Moment Matching Estimation)
%	fml: 	feature vectors based on generalized Gaussian pdf parameters
%		(Maximum Likelihood Estimation)
%	we:	entropy of wavelet subbands

% Read in the image
if ischar(file)
    im = imread(file);
	
    % If image is true color, convert it into an intensity image
    if ndims(im) == 3
        im = double(rgb2gray(im));
    else
        im = double(im);
    end
else
    % Input as a matrix
    im = double(file);
end

% Normalize grayscale values to zero mean and unit variance
% This reduces the effect of bias in evaluation since our "similar"
% images might share the same mean or variance.  Also features computed
% from now on will be invariant to shift and scale of gray-level values.
im = (im - mean2(im)) ./ std2(im);%归一化为0均值

% Standard wavelet decomposition
[c, s] = wavedec2(im, nlevels, LoF, HiF);
%s记录的分别低通波段大小 nlevels级方向子带的大小 原始影像的大小，共计nvlevels+2个长度,
%s(length(s)-1,1)为第一级分解的子带大小， s(length(s)-2,1)为第二级。。。。 s(2,1)为最后一级分解大小
%c的存放顺序与s对应，先存低通，再最后一级的H,V,D三个方向子带，借着存上一级，直到第一级


nbands = 3 * nlevels;

% Two features for each subband
fm  = zeros(2 * nbands, 1);
fmm = zeros(2 * nbands, 1);
fml = zeros(2 * nbands, 1);

% And one entropy weight for each
we = zeros(nbands, 1);

% Options for use in GGMLE
options = optimset('display', 'off', 'TolX', 1e-6, 'MaxIter', 10);

for b = 1:nbands
    band = sbcoef2(c, s, b);
    
    % Features from energies (feature vector 1)
    m1 = mean(abs(band));
    m2 = mean(band .^ 2);    
    fm(2*b-1:2*b) = [m1, sqrt(m2)];
    
    % Features from model parameters
    % that estimated from moment matching (feature vector 2)    
    % [alpha, beta] = sbpdf(m1, m2);
    [alpha, beta] = estpdf(m1, m2);
    fmm(2*b-1:2*b) = [alpha, beta];
    
    % Features from model parameters
    % that use maximum likelihood estimation
    [alpha, beta] = ggmle(band, options);
    fml(2*b-1:2*b) = [alpha, beta];
    
    % Compute entropy weight of the subband  子波段的熵权重  
    p = band(band).^2 / norm(band)^2;%find(band)返回band中所有非0的位置
    we(b) = -sum(p .* log2(eps+p));
end
