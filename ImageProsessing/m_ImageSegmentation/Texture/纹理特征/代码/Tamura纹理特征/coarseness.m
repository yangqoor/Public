function Fcrs = coarseness( graypic,kmax )%graphic为待处理的灰度图像，2^kmax为最大窗口
%计算粗糙度
%调用举例：  
%image=rgb2gray(imread('example.jpg'));  
%f=coarseness(image,5)  

[h,w]=size(graypic); %获取图片大小  
A=zeros(h,w,2^kmax); %平均灰度值矩阵A  
%计算有效可计算范围内每个点的2^k邻域内的平均灰度值  
for i=2^(kmax-1)+1:h-2^(kmax-1)  
    for j=2^(kmax-1)+1:w-2^(kmax-1)  
        for k=1:kmax  
            A(i,j,k)=mean2(graypic(i-2^(k-1):i+2^(k-1)-1,j-2^(k-1):j+2^(k-1)-1));  
        end  
    end  
end  
%对每个像素点计算在水平和垂直方向上不重叠窗口之间的Ak差  
Sbest=[];
for i=1+2^(kmax-1):h-2^(kmax-1)  
    for j=1+2^(kmax-1):w-2^(kmax-1)  
        for k=1:kmax  
            Eh(i,j,k)=abs(A(i+2^(k-1),j,k)-A(i-2^(k-1),j));  
            Ev(i,j,k)=abs(A(i,j+2^(k-1),k)-A(i,j-2^(k-1)));  
        end  
    end  
end  
%对每个像素点计算使E达到最大值的k  
for i=2^(kmax-1)+1:h-2^(kmax-1)  
    for j=2^(kmax-1)+1:w-2^(kmax-1)  
        [maxEh,p]=max(Eh(i,j,:));  
        [maxEv,q]=max(Ev(i,j,:));  
        if maxEh>maxEv  
            maxkk=p;  
        else  
            maxkk=q;  
        end  
        Sbest(i,j)=2^maxkk; %每个像素点的最优窗口大小为2^maxkk  
    end  
end  
%所有Sbest的均值作为整幅图片的粗糙度  
Fcrs=mean2(Sbest);  
end  



