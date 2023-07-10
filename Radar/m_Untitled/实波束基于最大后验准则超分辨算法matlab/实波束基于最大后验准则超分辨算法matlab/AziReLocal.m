%�Ժ�·���ݽ��з�λ���ض�λ
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
       M = ceil((AziAngle(k,m)*180/pi-minvalue)/lianghua);%ȷ����λ�����ݵ�Ԫ��
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
  %д������
for m =1:CpiNum*N
    fwrite(FidWriteReal,AziReLocalDataReal(m,:),'float32');
    fwrite(FidWriteImag,AziReLocalDataImag(m,:),'float32');
    
end
fclose all;