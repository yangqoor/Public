function Fcrs = coarseness( graypic,kmax )%graphicΪ������ĻҶ�ͼ��2^kmaxΪ��󴰿�
%����ֲڶ�
%���þ�����  
%image=rgb2gray(imread('example.jpg'));  
%f=coarseness(image,5)  

[h,w]=size(graypic); %��ȡͼƬ��С  
A=zeros(h,w,2^kmax); %ƽ���Ҷ�ֵ����A  
%������Ч�ɼ��㷶Χ��ÿ�����2^k�����ڵ�ƽ���Ҷ�ֵ  
for i=2^(kmax-1)+1:h-2^(kmax-1)  
    for j=2^(kmax-1)+1:w-2^(kmax-1)  
        for k=1:kmax  
            A(i,j,k)=mean2(graypic(i-2^(k-1):i+2^(k-1)-1,j-2^(k-1):j+2^(k-1)-1));  
        end  
    end  
end  
%��ÿ�����ص������ˮƽ�ʹ�ֱ�����ϲ��ص�����֮���Ak��  
Sbest=[];
for i=1+2^(kmax-1):h-2^(kmax-1)  
    for j=1+2^(kmax-1):w-2^(kmax-1)  
        for k=1:kmax  
            Eh(i,j,k)=abs(A(i+2^(k-1),j,k)-A(i-2^(k-1),j));  
            Ev(i,j,k)=abs(A(i,j+2^(k-1),k)-A(i,j-2^(k-1)));  
        end  
    end  
end  
%��ÿ�����ص����ʹE�ﵽ���ֵ��k  
for i=2^(kmax-1)+1:h-2^(kmax-1)  
    for j=2^(kmax-1)+1:w-2^(kmax-1)  
        [maxEh,p]=max(Eh(i,j,:));  
        [maxEv,q]=max(Ev(i,j,:));  
        if maxEh>maxEv  
            maxkk=p;  
        else  
            maxkk=q;  
        end  
        Sbest(i,j)=2^maxkk; %ÿ�����ص�����Ŵ��ڴ�СΪ2^maxkk  
    end  
end  
%����Sbest�ľ�ֵ��Ϊ����ͼƬ�Ĵֲڶ�  
Fcrs=mean2(Sbest);  
end  



