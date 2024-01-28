function x=myReblurL2_PreCompL(CImg, psf, we, ConstArgs)

FreqC = fft2(CImg);
b=ConstArgs.FreqF.*ConstArgs.FreqWt.*FreqC;
A=ConstArgs.FreqWt+we*ConstArgs.FreqLap;
X=b./A;
x=real(ifft2(X));

return