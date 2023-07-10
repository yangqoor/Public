
% 相参积累
FidReadReal = fopen('RanCompTurnRealSum.dat','r');
FidReadImage= fopen('RanCompTurnImageSum.dat','r');
FidWriteReal= fopen('SinglePulseSumReal.dat','w');
FidWriteImage= fopen('SinglePulseSumImage.dat','w');

for m =1:NrNew
    Data = fread(FidReadReal,Na,'float32')+1j*fread(FidReadImage,Na,'float32');
%     Data = fread(FidReadReal,'float32')+1j*fread(FidReadImage,'float32');
    SumData = fft(Data);
   
    fwrite(FidWriteReal,real(SumData),'float32');
    fwrite(FidWriteImage,imag(SumData),'float32');
    
end
fclose all;


% 相参积累
FidReadReal = fopen('RanCompTurnRealAzi.dat','r');
FidReadImage= fopen('RanCompTurnImageAzi.dat','r');
FidWriteReal= fopen('SinglePulseAziReal.dat','w');
FidWriteImage= fopen('SinglePulseAziImage.dat','w');

for m =1:NrNew
    Data = fread(FidReadReal,Na,'float32')+1j*fread(FidReadImage,Na,'float32');
    SumData = fft(Data);
   
    fwrite(FidWriteReal,real(SumData),'float32');
    fwrite(FidWriteImage,imag(SumData),'float32');
    
end
fclose all;


% 相参积累
FidReadReal = fopen('RanCompTurnRealEle.dat','r');
FidReadImage= fopen('RanCompTurnImageEle.dat','r');
FidWriteReal= fopen('SinglePulseEleReal.dat','w');
FidWriteImage= fopen('SinglePulseEleImage.dat','w');

for m =1:NrNew
    Data = fread(FidReadReal,Na,'float32')+1j*fread(FidReadImage,Na,'float32');
    SumData = fft(Data);
   
    fwrite(FidWriteReal,real(SumData),'float32');
    fwrite(FidWriteImage,imag(SumData),'float32');
    
end
fclose all;