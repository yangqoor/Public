function StringPic
sizecol=256;
OriPic=imread('1.jpg');
tempcol=size(OriPic,2);
tempmul=sizecol/tempcol;
OriPic=imresize(OriPic,tempmul,'nearest');
GraPic=sum(OriPic,3)./3;
if any(GraPic>1)
    GraPic=GraPic./255;
end
FillChar='$W&@E#8}]=+;;,,..  ';
FillChar_Len=length(FillChar);
GraPic=floor(GraPic./(1/(FillChar_Len-1)))+1;
for i=1:size(GraPic,1)
    for j=1:size(GraPic,2)
        StrPic(i,j)=FillChar(GraPic(i,j));
    end
end
filename='test.txt';
writematrix(StrPic,filename,'delimiter','tab')
end
