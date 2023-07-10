%调用举例：  
%image=rgb2gray(imread('example.jpg'));  
%Flin=linelikeness(image,sita,4) %sita为directionality.m返回的结果  
function Flin=linelikeness(graypic,sita,d) %d为共生矩阵计算时的像素间隔距离  
n=16;  
[h,w]=size(graypic);  
%构造方向共生矩阵  
PDd1=zeros(n,n);  
PDd2=zeros(n,n);  
PDd3=zeros(n,n);  
PDd4=zeros(n,n);  
PDd5=zeros(n,n);  
PDd6=zeros(n,n);  
PDd7=zeros(n,n);  
PDd8=zeros(n,n);  
for i=d+1:h-d-2  
    for j=d+1:w-d-2  
        for m1=1:n  
            for m2=1:n  
                %下方向   
                if (sita(i,j)>=(2*(m1-1)*pi/2/n) && sita(i,j)<((2*(m1-1)+1)*pi/2/n)) && (sita(i+d,j)>=(2*(m2-1)*pi/2/n) && sita(i+d,j)<((2*(m2-1)+1)*pi/2/n))  
                    PDd1(m1,m2)=PDd1(m1,m2)+1;  
                end  
                %上方向  
                if (sita(i,j)>=(2*(m1-1)*pi/2/n) && sita(i,j)<((2*(m1-1)+1)*pi/2/n)) && (sita(i-d,j)>=(2*(m2-1)*pi/2/n) && sita(i-d,j)<((2*(m2-1)+1)*pi/2/n))  
                    PDd2(m1,m2)=PDd2(m1,m2)+1;  
                end  
                %右方向  
                if (sita(i,j)>=(2*(m1-1)*pi/2/n) && sita(i,j)<((2*(m1-1)+1)*pi/2/n)) && (sita(i,j+d)>=(2*(m2-1)*pi/2/n) && sita(i,j+d)<((2*(m2-1)+1)*pi/2/n))  
                    PDd3(m1,m2)=PDd3(m1,m2)+1;  
                end  
                %左方向  
                if (sita(i,j)>=(2*(m1-1)*pi/2/n) && sita(i,j)<((2*(m1-1)+1)*pi/2/n)) && (sita(i,j-d)>=(2*(m2-1)*pi/2/n) && sita(i,j-d)<((2*(m2-1)+1)*pi/2/n))  
                    PDd4(m1,m2)=PDd4(m1,m2)+1;  
                end  
                %右下方向  
                if (sita(i,j)>=(2*(m1-1)*pi/2/n) && sita(i,j)<((2*(m1-1)+1)*pi/2/n)) && (sita(i+d,j+d)>=(2*(m2-1)*pi/2/n) && sita(i+d,j+d)<((2*(m2-1)+1)*pi/2/n))  
                    PDd5(m1,m2)=PDd5(m1,m2)+1;  
                end  
                %右上方向  
                if (sita(i,j)>=(2*(m1-1)*pi/2/n) && sita(i,j)<((2*(m1-1)+1)*pi/2/n)) && (sita(i-d,j+d)>=(2*(m2-1)*pi/2/n) && sita(i-d,j+d)<((2*(m2-1)+1)*pi/2/n))  
                    PDd6(m1,m2)=PDd6(m1,m2)+1;  
                end  
                %左下方向  
                if (sita(i,j)>=(2*(m1-1)*pi/2/n) && sita(i,j)<((2*(m1-1)+1)*pi/2/n)) && (sita(i+d,j-d)>=(2*(m2-1)*pi/2/n) && sita(i+d,j-d)<((2*(m2-1)+1)*pi/2/n))  
                    PDd7(m1,m2)=PDd7(m1,m2)+1;  
                end  
                %左上方向  
                if (sita(i,j)>=(2*(m1-1)*pi/2/n) && sita(i,j)<((2*(m1-1)+1)*pi/2/n)) && (sita(i-d,j-d)>=(2*(m2-1)*pi/2/n) && sita(i-d,j-d)<((2*(m2-1)+1)*pi/2/n))  
                    PDd8(m1,m2)=PDd8(m1,m2)+1;  
                end  
            end  
        end  
    end  
end  
f=zeros(1,8);  
g=zeros(1,8);  
for i=1:n  
    for j=1:n  
        f(1)=f(1)+PDd1(i,j)*cos((i-j)*2*pi/n);  
        g(1)=g(1)+PDd1(i,j);  
        f(2)=f(2)+PDd2(i,j)*cos((i-j)*2*pi/n);  
        g(2)=g(2)+PDd2(i,j);  
        f(3)=f(3)+PDd3(i,j)*cos((i-j)*2*pi/n);  
        g(3)=g(3)+PDd3(i,j);  
        f(4)=f(4)+PDd4(i,j)*cos((i-j)*2*pi/n);  
        g(4)=g(4)+PDd4(i,j);  
        f(5)=f(5)+PDd5(i,j)*cos((i-j)*2*pi/n);  
        g(5)=g(5)+PDd5(i,j);  
        f(6)=f(6)+PDd6(i,j)*cos((i-j)*2*pi/n);  
        g(6)=g(6)+PDd6(i,j);  
        f(7)=f(7)+PDd7(i,j)*cos((i-j)*2*pi/n);  
        g(7)=g(7)+PDd7(i,j);  
        f(8)=f(8)+PDd8(i,j)*cos((i-j)*2*pi/n);  
        g(8)=g(4)+PDd8(i,j);  
    end  
end  
tempM=f./g;  
Flin=max(tempM);%取8个方向的线性度最大值作为图片的线性度  
end  

