Nwin = round(Nr*Br/Fs/2)*2;
WinRan = fftshift( [zeros((Nr-Nwin)/2,1) ; hamming(Nwin) ; zeros((Nr-Nwin)/2,1) ]);
Hran = WinRan.*conj(fft(rectpuls(-Tp/2:1/Fs:Tp/2-1/Fs)',Tp).*exp(1j*pi*Br/Tp*(-Tp/2:1/Fs:Tp/2-1/Fs)'.^2),Nr);

FidReadReal = fopen('EchoRealAzi.dat','r');
FidReadImage= fopen('EchoImagAzi.dat','r');
FidWriteReal= fopen('RanCompRealAzi.dat','w');
FidWriteImage= fopen('RanCompImageAzi.dat','w');


for m=1:Na
   Data = fread(FidReadReal,Nr,'float32') +1j* fread(FidReadImage,Nr,'float32');
   Data = ifft(fft(Data).*Hran.*exp(-2j*pi*FdcRefCalcu*ta(m)*(fr*Lambda/C)));
   
   fwrite(FidWriteReal,real(Data(1:NrNew)),'float32');
   
   fwrite(FidWriteImage,imag(Data(1:NrNew)),'float32');
end
fclose all;
save StepRanCompAzi;