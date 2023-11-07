function [xx, yy, thetaEstSS, numSamples, counter, BGOut] = ...
    edgePixelSamplingAuto(BIn, sliceSize, perfectOrientation, stdnoiseB, imNo)

if(size(BIn, 3) == 3)
    BS = rgb2gray(BIn);
else
    BS = BIn;
end

% Gradient filters for edge detection
gyT = zeros(5, 5);
gyT(:, 1:2) = -1;
gyT(:, 4:5) = 1;
gxT = zeros(5, 5);
gxT(1:2, :) = -1; 
gxT(4:5, :) = 1; 

gf = fspecial('gaussian', 5, 1);
gy = gyT.*gf;
gx = gxT.*gf;

% Mask for valid edge pixels
mask = zeros(size(BS, 1), size(BS, 2));    
mask(2*sliceSize+1:end-2*sliceSize, 2*sliceSize+1:end-2*sliceSize) = 1;

%%
% Down-sample the image
%%%
downSampRat = 7/sliceSize;%6/sliceSize;%7/sliceSize;%5/sliceSize; 
BL = imresize(BS, downSampRat, 'bilinear');

% Computing gradients

BGxL = imconv(BL, gx, 'same');
BGyL = imconv(BL, gy, 'same');
BGxLG = imconv(BGxL, gf, 'same');
BGyLG = imconv(BGyL, gf, 'same');
BGL = sqrt(BGxLG.^2 + BGyLG.^2);

M = (BGxLG ==0); 
tanBL = -BGyLG./(BGxLG + eps*M);
thetaEst = atan(tanBL); 

thetaMapL = imresize(thetaEst, [size(BS, 1), size(BS, 2)], 'nearest');
BG = imresize(BGL, [size(BS, 1), size(BS, 2)], 'bicubic');

% non-maximum suppression
[BGN] = nonmaxsup(BG, (pi/2 - thetaMapL)/pi*180, 7);%1.5);

wBGN = BGN;%./weightMap;

[histBGN, hC] = hist(wBGN(:), size(BGN,1)*size(BGN,2)/1000);
cumHistBGN = cumsum(histBGN);
cumHistBGN = cumHistBGN/cumHistBGN(end);

pcFindC = 0;
flagL = 0;
flagH = 0;

while(flagH == 0)
    pcFindC = pcFindC + 1;
    if(flagL == 0)
        if(cumHistBGN(pcFindC) > 0.975)%975)%82)
            flagL = 1;
            edgeThreshL = hC(pcFindC);
        end
    else
        if(cumHistBGN(pcFindC) > 0.985)%9)
            flagH = 1;
            edgeThreshH = hC(pcFindC);
        end
    end
end 

%% Edge thresholding
edgeMapH = (wBGN > edgeThreshL).*mask; 
edgeMapL = wBGN > edgeThreshL;

BGOut = BG > edgeThreshL; 

clear i
edgeMagMap = edgeMapL.*BG;
compThetaMap = exp(-i*2*thetaMapL);
r_compTM = real(compThetaMap).*edgeMagMap;
i_compTM = imag(compThetaMap).*edgeMagMap;

gfTM = fspecial('Gaussian', 2*sliceSize, sliceSize/2);%sliceSize);
rS_compTM = imconv(r_compTM, gfTM, 'same');
iS_compTM = imconv(i_compTM, gfTM, 'same');
eS_compTM = imconv(edgeMagMap, gfTM, 'same');
eS_compTM(eS_compTM == 0) = eps;
rA_compTM = rS_compTM./eS_compTM;
iA_compTM = iS_compTM./eS_compTM;

% The norm of the sum of local edge orientations -> the larger the more
% stable
norm_compTM = sqrt(rA_compTM.^2 + iA_compTM.^2).*edgeMapH;

% Edge candidates
normCompThresh = 0.97;%7; 
edgeCand = edgeMapH.*(norm_compTM>normCompThresh);
[xxH, yyH] = find(edgeCand == 1);
 
thetaEstH = zeros(size(xxH));
for l = 1:length(xxH)
    thetaEstH(l) = thetaMapL(xxH(l), yyH(l));
end

% Taking slices
% Half the length -> the slice is twice as large
hSliceSize = (sliceSize); 
interpScheme = '*linear';
xx = zeros(length(xxH), 1);
yy = zeros(length(yyH), 1);
gradVar = zeros(length(yyH), 1);
counter = 0;
for l = 1:length(xxH)
    theta = -thetaEstH(l) + pi/2;

    xC = xxH(l);
    yC = yyH(l);

    % Take the slice!

    % Rotation matrix
    R = [cos(theta), -sin(theta); sin(theta), cos(theta)];

    % new coordinates
    newCoord = R*[zeros(1, 2*hSliceSize-1); -(hSliceSize-1):1:(hSliceSize-1)] + ...
        repmat([xC; yC], [1, 2*hSliceSize-1]);

    % Cropping just the region of interest for speed
    xmin = max(floor(min(newCoord(1, :)))-6, 1);
    xmax = min(ceil(max(newCoord(1, :)))+6, size(BIn, 1));
    ymin = max(floor(min(newCoord(2, :)))-6, 1);
    ymax = min(ceil(max(newCoord(2, :)))+6, size(BIn,2));

    imC = edgeMapL(xmin:xmax, ymin:ymax, :);

    % Slicing operation    
    [y,x] = meshgrid(ymin:ymax, xmin:xmax);
    imSliceC = interp2(y,x, imC, newCoord(2, :)', newCoord(1, :)', interpScheme);
 
    if(sum(imSliceC) <= 1.3)                 
            counter = counter + 1;            
            xx(counter) = xC;            
            yy(counter) = yC;
    end
end

numSamples = counter;

xx(counter+1:end) = [];
yy(counter+1:end) = []; 

thetaEstSS = zeros(size(xx));
for l = 1:numSamples
    thetaEstSS(l) = thetaMapL(xx(l), yy(l));
end
