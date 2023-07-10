%对和路数据进行方位向重定位
FidReadReal = fopen('RanCompRealSum.dat','r');
FidReadImag = fopen('RanCompImagSum.dat','r');
FidWriteReal = fopen('AziReLocalRealSum.dat','w');
FidWriteImag = fopen('AziReLocalImagSum.dat','w');

beta = 4.2;
lianghua = beta/N;
ReLocalData =zeros(CpiNum*N,NrNew);
AziReLocalDataReal = zeros(CpiNum*N,NrNew);
AziReLocalDataImag = zeros(CpiNum*N,NrNew);

for k = 1:CpiNum
    
    DataCpiReal = fread(FidReadReal,NrNew,'float32');
    DataCpiImag = fread(FidReadImag,NrNew,'float32');
    
    
    for m =1:NrNew
        
       maxvalue =aziangle(k)+beta/2;
       minvalue =aziangle(k)-beta/2;
       M = ceil((AziAngle(k,m)*180/pi-minvalue)/lianghua);%确定方位向数据单元号
       for num = 1:N
           if M ==num
               AziReLocalDataReal((k-1)*N+num,m) = DataCpiReal(m);
               AziReLocalDataImag((k-1)*N+num,m) = DataCpiImag(m);
           else
               AziReLocalDataReal((k-1)*N+num,m) =0;
               AziReLocalDataImag((k-1)*N+num,m) =0;
           end
       end
    end
end
  %写入数据
for m =1:CpiNum*N
    fwrite(FidWriteReal,AziReLocalDataReal(m,:),'float32');
    fwrite(FidWriteImag,AziReLocalDataImag(m,:),'float32');
    
end
fclose all;