
FidReal = fopen( 'AziInforReal.dat', 'r');
FidImag = fopen( 'AziInforIamg.dat', 'r');
FidWrite = fopen( 'AziInfor.dat' ,'w');
TempMin = zeros ( CpiNum,1);
TempMax = zeros ( CpiNum,1);
RowNum = CpiNum;
for m = 1:RowNum
    DataReal = fread(FidReal , NrNew , 'float32');
    DataImag = fread(FidImag , NrNew , 'float32');
    Data = abs(DataReal +1j*DataImag);                 %取模量化
    
    TempMin(m) = min(Data);
    TempMax(m) = max(Data);
end

%最大值最小值削峰量化
DataMin = min (TempMin);
DataMax = max (TempMax);

%文件指针归位

frewind ( FidReal);
frewind ( FidImag);

for i = 1:CpiNum
     DataReal = fread(FidReal , NrNew , 'float32');
     DataImag = fread(FidImag , NrNew , 'float32');
     Data = abs(DataReal +1j*DataImag);   %取模量化
     
     Data = (Data-DataMin)/(DataMax-DataMin)*255 ;
     fwrite( FidWrite , uint8(Data),'uint8');
end