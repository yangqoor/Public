NrNew = 1024;

FidReadReal = fopen('RanCompRealSumTurn.dat','r');
FidReadImag= fopen('RanCompImagSumTurn.dat','r');
FidWriteReal = fopen('AziInforReal.dat','w');
FidWriteImag= fopen('AziInforIamg.dat','w');

for k =1:NrNew
Data_Sum = fread(FidReadReal,CpiNum,'float32')+1j*fread(FidReadImag,CpiNum,'float32');
AziInfor = ifft(fft(Data_Sum)'./fft(FSum));

fwrite(FidWriteReal,real(AziInfor),'float32');
fwrite(FidWriteImag,imag(AziInfor),'float32');
end

fclose all;

