function x=myPadDeconvReblurL2(I, psf, we, we2, ConstArgs)

% [n,m]=size(I);
% F=psf2otf(psf,[n,m]);
% denorm1 = abs(F).^2;

FreqB = fft2(I);
A=ConstArgs.FreqF2.*ConstArgs.FreqWt+we*ConstArgs.FreqDerrs;
b=ConstArgs.FreqConjF.*ConstArgs.FreqWt.*FreqB;
FreqC = b./A;

% FreqC=fft2(real(ifft2(FreqC)));
b=ConstArgs.FreqF.*ConstArgs.FreqWt.*FreqC;
A=ConstArgs.FreqWt+we2*ConstArgs.FreqDerrs;
X=b./A;
x=real(ifft2(X));

return