function x=myReblurL2_PreComp(CImg, psf, we, ConstArgs)

FreqC = fft2(CImg);
b=ConstArgs.FreqF.*ConstArgs.FreqWt.*FreqC;
A=ConstArgs.FreqWt+we*ConstArgs.FreqDerrs;
X=b./A;
x=real(ifft2(X));

return