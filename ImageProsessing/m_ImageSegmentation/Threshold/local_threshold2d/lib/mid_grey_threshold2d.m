function th = mid_grey_threshold2d(im,n,c)
%%  mid_grey_threshold2d - MidGrey's threshold algorithm 
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

%% convert image to gray scale image
im = double(im2uint8(im));

%% kernel
h = strel('disk',n);

%% local min
lmin = imerode(im,h);

%% local max
lmax = imdilate(im,h);

%% level
level = (lmin + lmax)/2 - c ;

%% threshold
th = im > level;

end