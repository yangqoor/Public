function CornerTurn (FileIn,FileOut,RowNum,ColNum,DivNum)

%为了在数据矩阵翻转时避免大数据占用内存，所以要把数据矩阵分成几份分别翻转
FidIn =  fopen(FileIn,'r');
FidOut = fopen(FileOut,'w');

%按列分数据矩阵
SubColNum = ColNum/DivNum; %翻转时每一份列的大小
Data = zeros(RowNum,SubColNum);%暂存每一小份的数据矩阵

for k = 1:DivNum
    frewind(FidIn);
    SpaceByteStart = 4*(k-1)*SubColNum;
    SpaceByteEnd = 4*(DivNum-k)*SubColNum;
    
    for m = 1:RowNum
        fseek( FidIn , SpaceByteStart ,'cof');
        Temp = fread( FidIn ,SubColNum ,'float32' );%把指针指向每一行的要处理的列的起始列
        Data(m,:) = Temp' ;
        fseek( FidIn , SpaceByteEnd , 'cof' );%把指针指向每一行的开始
        
    end
    
    for n = 1:SubColNum
        fwrite(FidOut,Data(:,n),'float32');%子矩阵翻转
    end

end
fclose (FidIn);
fclose (FidOut);
