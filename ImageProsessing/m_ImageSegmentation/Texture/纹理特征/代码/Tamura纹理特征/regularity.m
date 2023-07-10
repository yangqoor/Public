%调用举例：  
%image=rgb2gray(imread('example.jpg'));  
%Freg=regularity(image,64)  
function Freg=regularity(graypic,windowsize) %windowsize为计算规则度的子窗口大小  
[h,w]=size(graypic);  
k=0;  
crs=[];
con=[];
dire=[];

for i=1:windowsize:h-windowsize  
    for j=1:windowsize:w-windowsize  
        k=k+1;  
        crs(k)=coarseness(graypic(i:i+windowsize-1,j:j+windowsize-1),5); %粗糙度  
        con(k)=contrast(graypic(i:i+windowsize-1,j:j+windowsize-1)); %对比度  
        [dire(k),sita]=directionality(graypic(i:i+windowsize-1,j:j+windowsize-1));%方向度  
        lin=linelikeness(graypic(i:i+windowsize-1,j:j+windowsize-1),sita,4)*10; %线性度，*10与crs、con、dire同量级化  
    end  
end  
%求上述各参数的标准差  
Dcrs=std(crs,1);  
Dcon=std(con,1);  
Ddir=std(dire,1);  
Dlin=std(lin,1);
Freg=1-(Dcrs+Dcon+Ddir+Dlin)/4/100;
end
