function x=myPadDeconvL2_PreComp(I, psf, we, ConstArgs)

% [n,m]=size(I);
% F=psf2otf(psf,[n,m]);
% denorm1 = abs(F).^2;

FreqB = fft2(I);
A=ConstArgs.FreqF2.*ConstArgs.FreqWt+we*ConstArgs.FreqDerrs;
b=ConstArgs.FreqConjF.*ConstArgs.FreqWt.*FreqB;
X=b./A;
x=real(ifft2(X));

return




