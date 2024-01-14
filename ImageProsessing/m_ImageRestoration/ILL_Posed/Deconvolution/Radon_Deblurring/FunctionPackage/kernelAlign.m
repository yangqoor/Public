% This function aligns the kernel K such that the centroid of the kernel K
% is at the center of the kerne K
function KS = kernelAlign(K)

KCent = centroid(K);
hW = (size(K, 1)+1)/2;
centerShift = [hW;hW] - KCent(:);
centerShiftCeil = ceil(abs(centerShift));
cS = max(centerShiftCeil);

KST = zeros(size(K,1) + 4*cS, size(K,2) + 4*cS);
KST(2*cS + 1:end - 2*cS, ...
    2*cS + 1:end - 2*cS) = K;
[y,x] = meshgrid(1:size(KST, 2), 1:size(KST, 1));

KSTT = interp2(y,x, KST, y-centerShift(2), x-centerShift(1), 'linear');
KS = KSTT(cS + 1:end - cS, ...
    cS + 1:end - cS);

centroid(KS)