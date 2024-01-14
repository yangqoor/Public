function [xx, yy, thetaEstSS, numSamples, counter] = edgePixelSampling(BIn, sliceSize, perfectOrientation, savedData, numSamples, imNo)

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
 
% if we want perfect orietation, we should not down-sample
if(perfectOrientation == 1)
    BL = imconv(BS, gf, 'same'); 
else
    % if not perfect, down-sample

    downSampRat = 12/sliceSize;
    BL = imresize(BS, downSampRat);
end

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

% edgeThresh = 0.005;

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
edgeMapL = (wBGN > edgeThreshL).*mask;

% % non-maximum suppression
% [BGN] = nonmaxsup(BG, (pi/2 - thetaMapL)/pi*180, 1.5);
% edgeMapT = BGN > edgeThresh;
% 
% % output
% edgeMapL = edgeMapT.*mask; 
%% Sample

% Stability estimation
clear i
compThetaMap = exp(-i*2*thetaMapL.*edgeMapL);
r_compTM = real(compThetaMap).*edgeMapL;
i_compTM = imag(compThetaMap).*edgeMapL;

gfTM = fspecial('Gaussian', 2*sliceSize, sliceSize/2);
rS_compTM = imconv(r_compTM, gfTM, 'same').*edgeMapL;
iS_compTM = imconv(i_compTM, gfTM, 'same').*edgeMapL;
eS_compTM = imconv(edgeMapL, gfTM, 'same').*edgeMapL;
eS_compTM(eS_compTM == 0) = eps;
rA_compTM = rS_compTM./eS_compTM;
iA_compTM = iS_compTM./eS_compTM;

% The norm of the sum of local edge orientations -> the larger the more
% stable
norm_compTM = sqrt(rA_compTM.^2 + iA_compTM.^2);

% 1 = automatic with orientation histogram; 
% 2 = automatic without orientation
% 3 = User interaction
sampleMethod = 3; 

switch sampleMethod
    case 1
        orientHistogram = zeros(180,1);
        angleMapLT = ceil(((thetaMapL<0)*pi + thetaMapL)/pi*180);
        tau = 1;
        xx = zeros(numSamples, 1);
        yy = zeros(numSamples, 1);
        imSel = zeros(size(angleMapLT));
        norm_compTMS = norm_compTM;
        for l = 1:numSamples
            l
            orientScore = 1+exp(-tau*orientHistogram(angleMapLT));
            score = norm_compTMS.*orientScore;

            [xS, yS] = find(score == max(score(:)));
            xx(l) = xS(1);
            yy(l) = yS(1);
            score(xS,  yS) = 0;
            orientHistogram(angleMapLT(xS, yS)) = orientHistogram(angleMapLT(xS, yS)) + 1;

            norm_compTMS(xS, yS) = 0;
            imSel(xS, yS) = 1;
        end

    case 2

        stableSort = sort(norm_compTM(:), 'descend');
        cutStab = stableSort(numSamples);

        edgeCandMap = norm_compTM>=cutStab;

        [xx, yy] = find(edgeCandMap == 1);

    case 3

        numTrials = 30;
        winSW = 6;
        xx = zeros(numSamples, 1);
        yy = zeros(numSamples, 1);
        imSel = zeros(size(edgeMapL));      
        
        fileName = sprintf('%s%s%s%s', '../testData/userDataCounter_', num2str(imNo), '_', num2str(numTrials), '.mat');
        load(fileName);             

        if(savedData)
            fileName = sprintf('%s%s%s%s', '../testData/userData_', num2str(imNo), '_', num2str(numTrials), '_', num2str(counter), '.mat');
            load(fileName);     
            numSamples = 0;
            for l = 1:length(xSUser)
                xST = xSUser(l);
                yST = ySUser(l);

                winPatch = edgeMapL(xST-winSW : xST + winSW, ...
                    yST - winSW : yST + winSW);

                [xS, yS] = find(winPatch == 1);

                warning off;
                for k = 1:length(xS)
                    xx(numSamples + k) = round(xS(k) + xST - winSW);
                    yy(numSamples + k) = round(yS(k) + yST - winSW);
                    imSel(xx(numSamples + k), yy(numSamples + k)) = 1;
                end
                numSamples = numSamples + length(xS);
            end

            xx(numSamples + 1:end) = [];
            yy(numSamples + 1:end) = [];

        else
            
            xSUser = zeros(numTrials,1);
            ySUser = zeros(numTrials,1);        
            numSamples = 0;
            for l = 1:numTrials
                BInN = BIn/max(BIn(:));
                figure, imshow(BInN.*repmat(norm_compTM, [1, 1, size(BIn, 3)]) + 2*BIn/3)
                [yST, xST] = (ginput(1));

                if(xST < 0 | yST < 0 | xST > size(BS, 1) | yST > size(BS, 2))
                    break;
                end
                xSUser(l) = xST;
                ySUser(l) = yST;

                winPatch = edgeMapL(xST-winSW : xST + winSW, ...
                    yST - winSW : yST + winSW);

                [xS, yS] = find(winPatch == 1);

                for k = 1:length(xS)
                    xx(numSamples + k) = round(xS(k) + xST - winSW);
                    yy(numSamples + k) = round(yS(k) + yST - winSW);
                    imSel(xx(numSamples + k), yy(numSamples + k)) = 1;
                end
                numSamples = numSamples + length(xS);
                close all;
                
            end 
            xx(numSamples + 1:end) = [];
            yy(numSamples + 1:end) = [];
            
            xSUser(l:end) = [];
            ySUser(l:end) = [];            

            counter = counter + 1;
            
            fileName = sprintf('%s%s%s%s', '../testData/userData_', num2str(imNo), '_', num2str(numTrials), '_', num2str(counter), '.mat');
            save(fileName, 'xSUser', 'ySUser');

            fileName = sprintf('%s%s%s%s', '../testData/userDataCounter_', num2str(imNo), '_', num2str(numTrials), '.mat');
            save(fileName, 'counter');
            
            % printing user input
            BC = repmat(BS, [1, 1, 3]);
            BC(:, :, 1) = BC(:, :, 1) + imSel;
            figure, imshow(BC)
            if(perfectOrientation)
                fileName = sprintf('%s%s%s%s', './Results/selectedEdges_POrient_', num2str(imNo), '.eps');
            else
                fileName = sprintf('%s%s%s%s', './Results/selectedEdges_EstOrient_', num2str(imNo), '.eps');
            end
            print('-depsc', fileName);
        end

        % printing user input
        BC = repmat(BS, [1, 1, 3]);
        BC(:, :, 1) = BC(:, :, 1) + imSel;
        figure, imshow(BC)
        if(perfectOrientation)
            fileName = sprintf('%s%s%s%s', './Results/selectedEdges_POrient_', num2str(imNo), '.eps');
        else
            fileName = sprintf('%s%s%s%s', './Results/selectedEdges_EstOrient_', num2str(imNo), '.eps');
        end
        print('-depsc', fileName);
end

thetaEstSS = zeros(size(xx));
for l = 1:numSamples
    thetaEstSS(l) = thetaMapL(xx(l), yy(l));
end
