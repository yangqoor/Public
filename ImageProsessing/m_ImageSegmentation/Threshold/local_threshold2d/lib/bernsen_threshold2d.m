function th = bernsen_threshold2d(im,n,c)
%%  bernsen_threshold2d - Bernsen's threshold algorithm 
%   
%   REFERENCE:
%       M. Sezgin and B. Sankur,
%       Survey over image thresholding techniques 
%       and quantitative performance evaluation, 
%       Journal of Electronic Imaging, 13, 1, 146-165, 2004
%
%       B. Obara, M. Roberts, J. Armitage, and V. Grau. 
%       Bioimage informatics approach for bacterial cells identification 
%       in Differential Interference Contrast microscopy images, 
%       BMC Bioinformatics, 14, 134, 2013
%   
%   INPUT:
%       im      - input image
%       n       - window size, 31
%       c       - constant threshold value, 15
%
%   OUTPUT:
%       th      - output image
%
%   AUTHOR:
%       Boguslaw Obara

%% setup - fill in unset optional values.
switch nargin
    case 1
        n = 31;
        c = 15;
    case 2
        c = 15;
end

%% convert image to gray scale
im = double(im2uint8(im));

%% kernel
h = strel('disk',n);

%% local min
lmin = imerode(im,h);

%% local max
lmax = imdilate(im,h);

%% local contrast
lc = lmax - lmin;

%% middle gray
mg = (lmin + lmax)/2;

%% if by indexing
ix1 = lc < c;
ix2 = lc >= c;

%% threshold
th = zeros(size(im))==1;
th(ix1) = mg(ix1) >= 128;
th(ix2) = im(ix2) >= mg(ix2);

end