function [cA, cB] = domColorEst(im, xC, yC, R, sliceSize)

hPatchSize = ceil(sliceSize/8);
baseColorCoord = R*[0, 0;-1*ceil(0.7*sliceSize), ceil(0.7*sliceSize)] + ...%[0, 0;-1*ceil(0.9*sliceSize), ceil(0.9*sliceSize)] + ...
    repmat([xC; yC], [1, 2]);
baseColorCoord = floor(baseColorCoord);

% im = im/max(im(:));
patchA =im(baseColorCoord(1, 1) - hPatchSize : baseColorCoord(1, 1) + hPatchSize, ...
    baseColorCoord(2,1) - hPatchSize : baseColorCoord(2,1) + hPatchSize, :);
patchB =im(baseColorCoord(1,2) - hPatchSize : baseColorCoord(1,2) + hPatchSize, ...
    baseColorCoord(2, 2) - hPatchSize : baseColorCoord(2, 2) + hPatchSize, :);

gf = fspecial('Gaussian', 2*hPatchSize+1, hPatchSize/2);
gf = repmat(gf, [1, 1, size(patchA, 3)]);


% im(baseColorCoord(1, 1) - hPatchSize : baseColorCoord(1, 1) + hPatchSize, ...
%     baseColorCoord(2,1) - hPatchSize : baseColorCoord(2,1) + hPatchSize, :) = gf/max(gf(:));
% im(baseColorCoord(1,2) - hPatchSize : baseColorCoord(1,2) + hPatchSize, ...
%     baseColorCoord(2, 2) - hPatchSize : baseColorCoord(2, 2) + hPatchSize, :)=1-gf/max(gf(:));

cAT = sum(sum(gf.*patchA, 2), 1);
cBT = sum(sum(gf.*patchB, 2), 1);
cA = reshape(cAT, [size(patchA, 3), 1]);
cB = reshape(cBT, [size(patchB, 3), 1]);
% 
% cAVT = (patchA - repmat(cAT, [size(patchA, 1), size(patchA, 2)])).^2;
% cBVT = (patchB - repmat(cBT, [size(patchB, 1), size(patchB, 2)])).^2;
% cAV = mean(cAVT(:));
% cBV = mean(cBVT(:));
