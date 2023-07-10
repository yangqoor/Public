function imgSegmented = segmentationLBP(inImg, nClusters, winDims, winStep, isGrayScale)
%% segmentationLBP
% The function performs image segmentation using its LBP sub-image histogram.
%
%% Syntax
%  imgSegmented = segmentationLBP(inImg);
%  imgSegmented = segmentationLBP(inImg, nClusters);
%  imgSegmented = segmentationLBP(inImg, nClusters, winDims);
%  imgSegmented = segmentationLBP(inImg, nClusters, winDims, winStep);
%  imgSegmented = segmentationLBP(inImg, nClusters, winDims, winStep, isGrayScale);
%
%% Description
% The function implements a rather primitive scheme for image segmentation. Each sub-image is
% processed using "blockproc" to acquire a feature vector for the central sub-image pixel from
% sub-image LBP histogram. Thus a 3D matrix is acquired. Each pixel feature vector along the matrix
% 3�d dimension is clustered via K-means clustering. As a result, each pixel is clustered resulting
% in image segmentation scheme. image->feature vectors->clustering->segmented image The scheme is
% quiet primitive and can be improved in multiple ways. It is merely implemented to explain a basic
% segmentation scheme and a platform to compare various feature spaces.
%
%% Input arguments (defaults exist):
% inImg- input image, or an image file name.
% nClusters- number of clusters used by the K-means Clustering. Should be similar to number of
%   segments in the image. Default value- 3.
% winDims- 2 elements vector specifying the dimensions of the sub image processed via "blockproc" to
%   generate feature vector. Default value [31, 31], resulting in 32x32 sub-image.
% winStep- 2 elements vector specifying the steps [columns, rows] between processed windows. Minimal
%   value of [1, 1] will result in pixel-wise image processing- very intensive in computational and
%   memory aspects. Default value [1, 1]- achieving maximal precision.
% isGrayScale- a logical flag. When enabled- true converts the input image to grayscale. processing
%   all colors of and RGB image is computationally intensive while the results improvement in not
%   high. Default value- true.
%
%% Output arguments
%   imgSegmented- the segmented image.
%
%% Issues & Comments
% - This scheme is not efficient, but clear and allows easy understanding, and good comparison to
%   other schemes GLCM and Statistical Moments.
% - In case of "out of memory errors" reduce image dimensions, enable isGrayScale, increase winStep.
% - Static environment is used to achieve better memory utilization and run time.
%
%% Example
% See segmentationDemo
% inImg = imread('tm1_1_1.png');
% inImg = imresize(inImg, 1/4, 'bicubic');
% imgSegmented = segmentationLBP(inImg, 3, [31, 31], [1, 1], true);
% figure;
% subplot(1, 2, 1);
% imshow(inImg);
% title('Input texture image', 'FontSize', 18);
% subplot(1, 2, 2);
% imshow(imgSegmented, []);
% title('Resulting segmentation LBP', 'FontSize', 18);
%
%% See also
% shiftBasedLBP - http://www.mathworks.com/matlabcentral/fileexchange/49787-shift-based-lbp
% segmentationGLCM          - similar function with GLCM based feature space
% segmentationStatMoments   - similar function with central statistical monmets based feature space
% segmentationDemo          - a demo script comparing segmentation schemes
% blockproc     - http://www.mathworks.com/help/images/ref/blockproc.html?searchHighlight=blockproc               
% k_means       - http://www.mathworks.com/matlabcentral/fileexchange/19344-efficient-k-means-clustering-using-jit
%
%% Revision history
% First version: Nikolay S. 2015-03-13.
% Last update:   Nikolay S. 2015-03-13.
%
% *List of Changes:*
% 2015-03-13- first release version.

%% Default input parameters
if nargin < 1
    inImg = [];
end
if nargin < 2
    nClusters = 3;
end
if nargin < 3
    winDims = [31, 31];
end
if nargin < 4
    winStep = [1, 1];
end
if nargin < 5
    isGrayScale = true;
end

if isempty(inImg)
    imageFormats=imformats;
    imageExtList=cat(2, imageFormats.ext);    % image files extentions
    inImg = filesFullName(inImg, imageExtList, 'Choose image file subject to segmentatiuon', true);
end
if ischar(inImg) && exist(inImg, 'file') == 2
    inImg = imread(inImg);
end

nClrs = size(inImg, 3);
if isGrayScale && nClrs==3
    inImg = rgb2gray(inImg);
    nClrs = 1;
end

%% Prepare feature space parameters
% Generale LBP image
filtR= generateRadialFilterLBP(8, 1, 'shiftBasedLBP');
imgLBP = shiftBasedLBP(inImg, 'filtR', filtR);

% Prepare for sliding window histogram generation

% take nMaxBinsLBP most frequent values bins in each color channel of current image
nMaxBinsLBP = 28;
imgValsLBP = zeros(nClrs, nMaxBinsLBP);
for iClr=1:nClrs
    currClrVals = single(reshape( imgLBP(:, :,iClr), [], 1 ));
    currClrUniqueVals = unique(currClrVals);
    [nBins, ~] = hist(currClrVals, currClrUniqueVals);
    [~, iSorBins]=sort(nBins, 'descend');
    imgValsLBP(iClr, :) = sort(currClrUniqueVals( iSorBins(1:nMaxBinsLBP) ), 'ascend');
end
nHistElems = numel(imgValsLBP)/nClrs;

%% Feature space generation
% Prepare sliding window params
winDims=winDims+mod(winDims+1, 2); % make diention odd
winNeigh=floor(winDims/2);
switch( class(inImg) )
    case('uint8')
        outClass = 'uint16';
    case('uint16')
        outClass = 'uint32';
    case('uint32')
        outClass = 'uint64';
    case('int8')
        outClass = 'int16';
    case('int16')
        outClass = 'int32';
    case('int32')
        outClass = 'int64';    
    case({'int64', 'uint64'})
        outClass = 'single';
    otherwise
        outClass = 'double';
end

imgFeatSpace=blockproc(imgLBP, winStep, @raw2FeatSpace, 'BorderSize', winNeigh,...
    'TrimBorder', false, 'PadPartialBlocks', true, 'PadMethod', 'symmetric' );

%% Perform K-means clusteirng based image segmentation using multi-dimentional feature space matrix
imgClusterDims = size(imgFeatSpace);
nRows=imgClusterDims(1)*imgClusterDims(2);
reorderedData = reshape(imgFeatSpace, nRows, []);
idxCluster = k_means( reorderedData, nClusters); % "k_means", use "kmeans" if you have statistical toolbox
imgSegmented = reshape(idxCluster, imgClusterDims(1), imgClusterDims(2) );

% Bring segmentation image to canonical form (to allow easier comparison of results)
imgSegmented = switchMatrixlabels(imgSegmented);

%% Nested Servise function trasfering row data to feature space vector of each sliding window
    function tightHistImgLBP=raw2FeatSpace(inSubImgLBP)
        tightHistImgLBP = zeros(1, 1, nHistElems*nClrs, outClass);
        for iSubImgClr=1:nClrs
            imImgVec=single(reshape( inSubImgLBP.data(:, :, iSubImgClr), [], 1 ));
            tightHistImgLBP( :, :, (iSubImgClr-1)*nHistElems+(1:nHistElems) )=...
                hist( imImgVec, imgValsLBP(iSubImgClr, :) ); % calculate histogram
        end
    end
end