function ResultDisplayRaw( FileReal , FileImag,FileResult , RowNum , ColNum )
FidReal = fopen( FileReal, 'r');
FidImag = fopen( FileImag, 'r');
FidResult = fopen( FileResult ,'w');

TempMin = zeros ( RowNum,1);
TempMax = zeros ( RowNum,1);
for m = 1:RowNum
    DataReal = fread(FidReal , ColNum , 'float32');
    DataImag = fread(FidImag , ColNum , 'float32');
    Data = abs(DataReal +1j*DataImag);                 %ȡģ����
    
    TempMin(m) = min(Data);
    TempMax(m) = max(Data);
end

%���ֵ��Сֵ��������
DataMin = min (TempMin);
DataMax = max (TempMax);

%�ļ�ָ���λ

frewind ( FidReal);
frewind ( FidImag);

for i = 1:RowNum
     DataReal = fread(FidReal , ColNum , 'float32');
     DataImag = fread(FidImag , ColNum , 'float32');
     Data = abs(DataReal +1j*DataImag);   %ȡģ����
     
     Data = (Data-DataMin)/(DataMax-DataMin)*255 ;
     fwrite( FidResult , uint8(Data),'uint8');
end


fclose all ;