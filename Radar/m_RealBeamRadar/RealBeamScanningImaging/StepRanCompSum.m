Nwin = round(Nr*Br/Fs/2)*2;
WinRan = fftshift( [zeros((Nr-Nwin)/2,1) ; hamming(Nwin) ; zeros((Nr-Nwin)/2,1) ]);
ref = exp(1j*Br/Tp*pi*((1:Tp*Fs)/Fs-Tp/2).^2);%����Ƶ
ss0 = zeros(1,Nr);
ss0(1:Tp*Fs)=(ref);
Hran = WinRan .*conj(fft(ss0)).';

FidReadReal = fopen('EcholRealSum.dat','r');
FidReadImag= fopen('EcholImagSum.dat','r');
FidWriteReal= fopen('RanCompRealSum.dat','w');
FidWriteImag= fopen('RanCompImagSum.dat','w');

DataLine =  zeros(CpiNum,Nr);

for m=1:CpiNum
    
    %��
   DataSum = fread(FidReadReal,Nr,'float32') +1j* fread(FidReadImag,Nr,'float32');
   DataSum = DataSum-mean(DataSum);
   DataSum = ifft(fft(DataSum).*Hran(1:end));
   DataLine(m,:) = DataSum;
   fwrite(FidWriteReal,real(DataSum(1:NrNew)),'float32');
   fwrite(FidWriteImag,imag(DataSum(1:NrNew)),'float32');
 
end
figure;
imagesc(abs(DataLine)),colormap gray;
title('��ѹ��Ҷ�ͼ');
xlabel('������');
ylabel('��λ��');
fclose all;
save StepRanCompSum

