function [PSlice, anglesEst, numActSamples, xxOut, yyOut, errOutCand, epsColor] = kernelProjection(B, xx, yy, thetaEstSS, sliceSize, numSamples)
                 

anglesEst = -thetaEstSS*180/pi + 90;     
numUnUsed = 0;
unUsedIdx = zeros(1, numSamples);

xxOut = xx;
yyOut = yy;

% Taking slices
PSlice = zeros(sliceSize, numSamples);
numActSamples = 0;
% Take the slice!
optSlice1D =0;
diffOn = 1;
zeroThresh = 1;
interpScheme = '*linear';


%% for color Diff
imNorm = sqrt(mean(B.^2, 3));
epsColor = 0.1*median(imNorm(:));

% error flags
errOutCand = struct('flag', 0, 'flag_cd', 0, 'flag_dp', 0, ...
    'flag_ma', 0, 'flag_mina', 0, ...
    'flag_ad', 0, 'cDiff', 0, ...
    'distProj', 0, 'maxAlpha', 0, ...
    'minAlpha', 0, 'alphaDiff', 0, 'counter', 0, 'xC', 0, 'yC', 0);

for l = 1:numSamples 
    %l
    theta = thetaEstSS(l);

    xC = xx(l);
    yC = yy(l);

    % Taking the slices of edges
    [slice, thetaObs, flipped, counter, xSCum, ySCum, errOut] = imSliceColor(B, xC, yC, -theta + pi/2, ...
        sliceSize, optSlice1D, diffOn, zeroThresh, epsColor, interpScheme);
    
    xxOut(l) = xC - xSCum;
    yyOut(l) = yC - ySCum;
    
    if(counter < 6 & (sum(isnan(slice(:))) == 0))
        numActSamples = numActSamples + 1;        
        PSlice(:, numActSamples) = slice(:);
        if(flipped == 1)
            anglesEst(l) = anglesEst(l) + 180;
        end
    else        
        numUnUsed = numUnUsed + 1;
        unUsedIdx(numUnUsed) = l;
    end
    errOut.counter = counter;
    
    errOut.xC = xC;
    errOut.yC = yC;
    
    errOutCand(l) = errOut;
end

unUsedIdx(numUnUsed + 1:end) = [];
anglesEst(unUsedIdx) = [];
xxOut(unUsedIdx) = [];
yyOut(unUsedIdx) = []; 

PSlice(:, numActSamples + 1:end) = [];
