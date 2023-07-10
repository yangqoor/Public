function chengxu()
%��1��
close all
I=imread('1.jpg');  %��ȡͼ��
I=rgb2gray(I);    %��ɫͼ��ת���ɻҶ�ͼ

% I=im2bw(I);      %��ֵ��
I=edge(double(I)); %���ͼ��ı�Ե
figure
imshow(I)          %��ʾ��Ե���Ľ��

%��2��

[m,n]=size(I);     %����ͼ��ĳߴ�

M=3;             %����X����ָ�Ŀ���
N=3;             %����Y����ָ�Ŀ���
mm=floor(m/M);   %�ӿ��еĳ���
nn=floor(n/N);   %�ӿ��еĳ���
count=1;         %������
figure
for i=1:M
    for j=1:N
        A=I((i-1)*mm+1:i*mm,(j-1)*nn+1:j*nn);    %�ָ�ԭͼ�񣬵õ�һ���ӿ�
        subplot(M,N,count)      
        imshow(A)               %��ʾһ���ӿ�
        zuoshangjiao=[(i-1)*mm+1 (j-1)*nn+1];  %�ӿ����Ͻǵ�����
        [x,y,k,b]=zikuai(A,zuoshangjiao);      %�õ��ӿ����ɫ���ص���ϵõ���ֱ�ߵ�б��k�ͽؾ�b������zikuai������
        X{count}=x;       %�����ӿ������а�ɫ���ص�x����
        Y{count}=y;       %�����ӿ������а�ɫ���ص�y����
        K(count)=k;       %�����ӿ�����ϵõ���ֱ�ߵ�б��k
        B(count)=b;       %�����ӿ�����ϵõ���ֱ�ߵĽؾ�b
        count=count+1;    %��������1��������һ���ӿ�ļ���
    end
end

%��3��
KK=K(~isnan(K));   %ȥ��K�е�NaN����ɫ���ص�����10���ӿ飩
BB=B(~isnan(B));   %ȥ��B�е�NaN����ɫ���ص�����10���ӿ飩

mean_K=mean(KK);   %������б�ʵ�ƽ��ֵ
mean_B=mean(BB);   %�����нؾ��ƽ��ֵ

figure
subplot(2,1,1)
plot(KK,'-o')
title('���ӿ���ϵõ���ֱ��kֵ')
subplot(2,1,2)
plot(BB,'-o')
title('���ӿ���ϵõ���ֱ��bֵ')

count1=1;
count2=1;
for i=1:length(K)
    if ~isnan(K(i))
        if K(i)>mean_K            %����б��ƽ��ֵ���ӿ飬����Щ�ӿ�İ�ɫ���ص�λ�ü��ϵ�cell������X1��Y1���ֱ��x��y��
            X1{count1}=X{i};
            Y1{count1}=Y{i};
            count1=count1+1;
        else                      %С��б��ƽ��ֵ���ӿ飬����Щ�ӿ�İ�ɫ���ص�λ�ü��ϵ�cell������X2��Y2���ֱ��x��y��
            X2{count2}=X{i};
            Y2{count2}=Y{i};
            count2=count2+1;
        end
    end
end

XX1=[];
YY1=[];
XX2=[];
YY2=[];

for i=1:length(X1)         %����б��ƽ��ֵ���ӿ飬����Щ�ӿ�İ�ɫ���ص�λ�ü��ϵ�double��������������
    XX1=[XX1;X1{i}];
    YY1=[YY1;Y1{i}];
end

for i=1:length(X2)         %С��б��ƽ��ֵ���ӿ飬����Щ�ӿ�İ�ɫ���ص�λ�ü��ϵ�double��������������
    XX2=[XX2;X2{i}];
    YY2=[YY2;Y2{i}];
end

%%%%%ֱ��1��ֱ��2����ͼ������ȡ�����˷ֱ�ΪXX1,YY1��XX2,YY2
%��ɢ����ϵõ�ֱ��1��б��k1�ͽؾ�b1
A1=[XX1,ones(length(XX1),1)];
kb1=A1\YY1;
k1=kb1(1);
b1=kb1(2);
            
%��ɢ����ϵõ�ֱ��2��б��k2�ͽؾ�b2
A2=[XX2,ones(length(XX2),1)];
kb2=A2\YY2;
k2=kb2(1);
b2=kb2(2);

xx0=[1 m];
yy0=[1 n];

yy1=k1*xx0+b1;  %�õ�ֱ��1�ϵ����㣬�Ա����ֱ��1
yy2=k2*xx0+b2;  %�õ�ֱ��3�ϵ����㣬�Ա����ֱ��2

%%%%������ϵõ���ֱ�ߺͷ����������ɢ��
%ֱ��1
figure
axis([1,m,1,n])    %�趨��ʾ��Χ
hold on
scatter(XX1,YY1,'LineWidth',5)   %����ֱ��1��Ӧ�İ�ɫ����λ��
plot(xx0,yy1,'r','LineWidth',3)  %������ϵ���ֱ��1

%ֱ��2
hold on
scatter(XX2,YY2,'k','LineWidth',5)  %����ֱ��2��Ӧ�İ�ɫ����λ��
plot(xx0,yy2,'y','LineWidth',3)     %������ϵ���ֱ��2

%��4��

%������ֱ�ߵĽ���
X0=(b2-b1)/(k1-k2);
Y0=k1*X0+b1;

alpha=atan(k1);    %ֱ��1��x�н�
beta=atan(k2);     %ֱ��2��x�н�

K01=tan((alpha+beta)/2);        %��ƽ����1��б��
K02=tan(-pi/2+(alpha+beta)/2);  %��ƽ����2��б��

B01=Y0-K01*X0;   %��ƽ����1�Ľؾ�
B02=Y0-K02*X0;   %��ƽ����2�Ľؾ�

%���ƽ�ƽ����
xx0=[1 m];
yy0=[1 n];

YY1=K01*xx0+B01;  %��ƽ����1
YY2=K02*xx0+B02;  %��ƽ����2
plot(xx0,YY1);    %���ƽ�ƽ����1
plot(xx0,YY2);    %���ƽ�ƽ����2

view([90 90])
end

function [x,y,k,b]=zikuai(feikuai,zuoshangjiao)
%��ÿ���ӿ�������ϳ�����ֱ��y=kx+b������k��b���Լ��ӿ����ɫ���ص������
x0=zuoshangjiao(1);     %�õ��ӿ�����Ͻ�x����
y0=zuoshangjiao(2);     %�õ��ӿ�����Ͻ�y����

[m,n]=size(feikuai);    %�����ӿ�Ĵ�С
N=1;                    %N��1��ʼ����
x=[];                   %�����ӿ��ɫ����x���걣�������x
y=[];                   %�����ӿ��ɫ����y���걣�������y
for i=1:m               %����ɨ���ӿ�����������ֵ
    for j=1:n
        if feikuai(i,j)==1  %����ǰ�ɫ���أ���������ص�����
            x(N)=i;     %����������꣨x����
            y(N)=j;     %����������꣨y����
            N=N+1;      %������1���ж���һ������
        end
    end
end

if length(x)<10   %����10����ɫ���ص��ӿ飨����û�а׵���ӿ飩��������������̫�٣�������������
    k=NaN;        %��k b x y ��ֵNaN��Matlabϵͳ��������ʾNot a Number������ʾ�������ӿ������
    b=NaN;
    x=NaN;
    y=NaN;
    return       %����
else             %�ӿ��ɫ���ص�������ڵ���10���԰�ɫ���ص�����������ϣ��õ�ֱ�ߵ�б��k�ͽؾ�b
    x=x+x0;      %�õ��ӿ��ڰ�ɫ���ص������ԭͼ��ľ�������x
    y=y+y0;      %�õ��ӿ��ڰ�ɫ���ص������ԭͼ��ľ�������y
    x=x';
    A=[x,ones(length(x),1)];    %�������A��ֱ����Ͼ��ǽⳬԽ���Է��������С���˽⣬δ֪��Ϊk��b����A*[k;b]=y';
    y=y';
    kb=A\y;                     %�õ���С���˽⣬��Ӧk��b     
    k=kb(1);                    %�õ�k
    b=kb(2);                    %�õ�b
end
end

            