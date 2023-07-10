function th = mean_threshold2d(im,n,c)
%%  mean_threshold2d - Mean's threshold algorithm 
%   
%   REFERENCE:
%       B. Obara, M. Roberts, J. Armitage, and V. Grau. 
%       Bioimage informatics approach for bacterial cells identification 
%       in Differential Interference Contrast microscopy images, 
%       BMC Bioinformatics, 14, 134, 2013
%   
%   INPUT:
%       im      - input image
%       n       - window size, 15 
%       c       - constant value, 0
%
%   OUTPUT:
%       th      - output image
%
%   AUTHOR:
%       Boguslaw Obara

%% setup - fill in unset optional values
switch nargin
    case 1
        n = 15;
        c = 0;
    case 2
        c = 0;
end

%% convert image to gray scale
im = double(im2uint8(im));

%% kernel
se = strel('disk',n);
h = double(getnhood(se));

%% local mean
% m = sum(x)/n
m  = imfilter(im,h,'symmetric') / sum(h(:)); 

%% level
level = m - c ;

%% threshold
th = im > level;

end