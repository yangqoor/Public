% This function takes a slice at [xC, yC] along the orientation given by
% theta.  The length of the slice is sliceSize
%
% I = image
% [xC, yC] = center of the slice
% theta = orientation at which we take the slice
% sliceSize = length of the slice
function [slice, theta, flipped, counter, xSCum, ySCum, errOut] = imSliceColor(im, xC, yC, theta, sliceSize, ...
    optShift1D, diffOn, zeroThresh, epsColor, interpScheme)

if ~exist('optShift1D', 'var')
    optShift1D = 0;
end

if ~exist('diffOn', 'var')
    diffOn = 0;
end

if ~exist('zeroThresh', 'var')
    zeroThresh = 1;
end

if ~exist('interpScheme', 'var')
    interpScheme = 'linear';
end

% This flag is 1 if the orientation is out of phase by pi
flipped = 0;

% Half the length
hSliceSize = (sliceSize+1)/2;

% Rotation matrix
R = [cos(theta), -sin(theta); sin(theta), cos(theta)];

% new coordinates
newCoord = R*[zeros(1, sliceSize); -(hSliceSize-1):1:(hSliceSize-1)] + ...
    repmat([xC; yC], [1, sliceSize]);

% Cropping just the region of interest for speed
xmin = max(floor(min(newCoord(1, :)))-hSliceSize, 1);
xmax = min(ceil(max(newCoord(1, :)))+hSliceSize, size(im, 1));
ymin = max(floor(min(newCoord(2, :)))-hSliceSize, 1);
ymax = min(ceil(max(newCoord(2, :)))+hSliceSize, size(im,2));

imC = im(xmin:xmax, ymin:ymax, :);

% Slicing operation
[y,x] = meshgrid(ymin:ymax, xmin:xmax);
imSliceC = zeros(sliceSize, size(imC, 3));
for l = 1:size(imC, 3)
    imSliceC(:, l) = interp2(y,x, imC(:, :, l), newCoord(2, :)', newCoord(1, :)', interpScheme);
end

%%%%%
%% Color projection
%%%%% 
epsAlpha = 0.03; 
alphaThresh = 1- 2*epsAlpha;

%% 
[cB, cA] = domColorEst(im, xC, yC, R, sliceSize);
 
[imSliceT, distProj] = alphaExtract(imSliceC', cA, cB);

% % Displaying the slice we are taking
imOutOn = 0;
if(imOutOn)
    imTTT = rgb2gray(im);
    imTTT = repmat(imTTT, [1, 1, 3]);
    imTTT(:, :, 2:3) = 0;

    nCC = ceil(newCoord);
    for k = 1:size(nCC, 2)
        imTTT(nCC(1, k), nCC(2, k), 2) = 1;
    end
    figure, imshow(imTTT)
end

minAlpha = min(imSliceT(:));
maxAlpha = max(imSliceT(:));

errOut.flag = 0;
errOut.flag_cd = 0;
errOut.flag_dp = 0;
errOut.flag_ma = 0;
errOut.flag_mina = 0;
errOut.flag_ad = 0;  

cDiff = sqrt(mean((cA - cB).^2));
if(cDiff < epsColor)
    errOut.flag = 1;
    errOut.flag_cd = 1;
end

if(max(distProj) > epsAlpha)
    errOut.flag = 1;
    errOut.flag_dp = 1;
end

if(maxAlpha > 1+epsAlpha)
    errOut.flag = 1;
    errOut.flag_ma = 1;
end

if(minAlpha < -epsAlpha)
    errOut.flag = 1;
    errOut.flag_mina = 1;
end

if(abs(imSliceT(1) - imSliceT(end)) < alphaThresh)
    errOut.flag = 1;
    errOut.flag_ad = 1;
end
 
errOut.cDiff = cDiff;
errOut.distProj = max(distProj);
errOut.maxAlpha = maxAlpha;
errOut.minAlpha = minAlpha;
errOut.alphaDiff = abs(imSliceT(1) - imSliceT(end));

if(errOut.flag)    
    counter = 100;
    slice = 0;
    theta = 0;
    flipped = 0;
    xSCum = 0;
    ySCum = 0;
    return;
end

% Differentiate if diffOn
if(diffOn)
    imSliceTT = imSliceT;
    imSliceT = zeros(size(imSliceTT));
    imSliceT(2:end) = imSliceTT(2:end) - imSliceTT(1:end-1);
end
 

if(zeroThresh == 1)
    imSliceT(imSliceT<0) = 0;
end
imSliceT = imSliceT/sum(imSliceT(:));
slice = imSliceT;

% Until the centroid is at the center of the slice, we keep on matching the
% centroid to the center.
diff = 10; % difference (in pixels) between the center of the slice to the centroid.
eps = 0.01; % the limit 
counter = 1;
xSCum = 0;
ySCum = 0;
while(diff > eps & counter < 10)
        
    % Aligning the slices
    % centroid of the slice.  This should be the center of the slice
    k = centroid(imSliceT(:));

    % The number of pixels to "shift" the slice
    centerShift = hSliceSize - k(1);
    centerShiftCeil = ceil(abs(centerShift));

    % Taking slice again, with the centroid of the slice at the center of the
    % slice.  We could do this either with the 1D slice directly, or do it
    % again from the 2D image.
    if(optShift1D == 1)
        imSliceTT = zeros(1, length(imSliceT) + 4*centerShiftCeil);
        imSliceTT(2*centerShiftCeil + 1:end - 2*centerShiftCeil) = imSliceT;
        slice = interp1([1:sliceSize + 4*centerShiftCeil], imSliceTT, ...
            [2*centerShiftCeil+[1:sliceSize] - centerShift], interpScheme);    
        % cent = centroid(slice(:));

    else 
        xS = centerShift*(cos(theta+pi/2));
        yS = centerShift*(sin(theta+pi/2)); 
        
        xSCum = xSCum + xS;
        ySCum = ySCum + yS;
 
        newCoord = newCoord - repmat([xS;yS], [1, size(newCoord, 2)]); %newCoord - repmat([xS;yS], [1, size(newCoord, 2)]);
 
%         % Cropping just the region of interest for speed
%%%%%%%%%%%%%%%%%%%%
        xmin = max(floor(min(newCoord(1, :)))-6, 1);
        xmax = min(ceil(max(newCoord(1, :)))+6, size(im, 1));
        ymin = max(floor(min(newCoord(2, :)))-6, 1);
        ymax = min(ceil(max(newCoord(2, :)))+6, size(im,2));

        imC = im(xmin:xmax, ymin:ymax, :);
%%%%%%%%%%%%%%%%%%%%
        % Slicing operation
        [y,x] = meshgrid(ymin:ymax, xmin:xmax);
        imSliceC = zeros(sliceSize, size(imC, 3));
        for l = 1:size(imC, 3)
            imSliceC(:, l) = interp2(y,x, imC(:, :, l), newCoord(2, :)', newCoord(1, :)', interpScheme);
        end
        
        %%%%%
        %% Color projection
        %%%%%
        slice = alphaExtract(imSliceC', cA, cB);

        % Differentiate if diffOn
        if(diffOn)
            imSliceTT = slice;
            slice= zeros(size(imSliceTT));
            slice(2:end) = imSliceTT(2:end) - imSliceTT(1:end-1);
            if(zeroThresh == 1)
                slice(slice<0) = 0;
            end
        end
    end

    cent = centroid(slice(:));
    diff = norm(cent(1) - hSliceSize);
    imSliceT = slice;
     
    counter = counter + 1;
end

 
xSCum = floor(xSCum);
ySCum = floor(ySCum);
slice = slice/sum(slice(:));
theta = theta - pi/2;
% counter
