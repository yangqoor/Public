%���þ�����  
%image=rgb2gray(imread('example.jpg'));  
%Freg=regularity(image,64)  
function Freg=regularity(graypic,windowsize) %windowsizeΪ�������ȵ��Ӵ��ڴ�С  
[h,w]=size(graypic);  
k=0;  
crs=[];
con=[];
dire=[];

for i=1:windowsize:h-windowsize  
    for j=1:windowsize:w-windowsize  
        k=k+1;  
        crs(k)=coarseness(graypic(i:i+windowsize-1,j:j+windowsize-1),5); %�ֲڶ�  
        con(k)=contrast(graypic(i:i+windowsize-1,j:j+windowsize-1)); %�Աȶ�  
        [dire(k),sita]=directionality(graypic(i:i+windowsize-1,j:j+windowsize-1));%�����  
        lin=linelikeness(graypic(i:i+windowsize-1,j:j+windowsize-1),sita,4)*10; %���Զȣ�*10��crs��con��direͬ������  
    end  
end  
%�������������ı�׼��  
Dcrs=std(crs,1);  
Dcon=std(con,1);  
Ddir=std(dire,1);  
Dlin=std(lin,1);
Freg=1-(Dcrs+Dcon+Ddir+Dlin)/4/100;
end
