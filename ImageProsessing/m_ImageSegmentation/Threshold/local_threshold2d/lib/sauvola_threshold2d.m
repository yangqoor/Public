function imth = sauvola_threshold2d(im,n,k,R)
%%  sauvola_threshold2d - Sauvola's threshold algorithm 
%   
%   REFERENCE:
%       J. Sauvola and M. Pietikainen, 
%       Adaptive document image binarization, 
%       Pattern Recognition, 33, 2, 225-236, 2000
%
%       B. Obara, M. Roberts, J. Armitage, and V. Grau. 
%       Bioimage informatics approach for bacterial cells identification 
%       in Differential Interference Contrast microscopy images, 
%       BMC Bioinformatics, 14, 134, 2013
%
%   INPUT:
%       im      - input image
%       n       - window size, 10-20 
%       k       - weight value, normally is a positive number in [0,1], 0.5
%       R       - dynamic range of the standard deviation, normally is 128 
%
%   OUTPUT:
%       th      - output image
%
%   AUTHOR:
%       Boguslaw Obara

%% setup - fill in unset optional values.
switch nargin
    case 1
        n = 15;
        k = 0.5;
        R = 128;        
    case 2
        k = 0.5;
        R = 128;        
    case 3
        R = 128;        
end
%% convert image to gray scale
im = double(im2uint8(im));

%% kernel
se = strel('disk',n);
h = double(getnhood(se));

%% local mean
% m = sum(x)/n
m  = imfilter(im,h,'symmetric') / sum(h(:)); 

%% local variance
% v = sum(x-m)^2/n = sum(x^2-2xm+m^2)/n = (sum(x^2)-2msum(x)+m^2)/n = 
%   = (sum(x^2)-2m^2+m^2)/n = sum(x^2)/n-m^2 
v  = imfilter(im.^2,h,'symmetric') / sum(h(:)) - m.^2; 
%% local std
s = sqrt(v);

%% level
level = m .* (1.0 + k * (s / R - 1.0));

%% threshold
imth = im > level;

end