function OUT=GrayGradinet(~)
% �Ҷ��ݶȹ������� H

%��һ���Ҷ��ݶȾ��� H_basic

%С�ݶ����� T1
% ���ݶ����� T2
% �Ҷȷֲ��Ĳ������� T3
% �ݶȷֲ��Ĳ������� T4
% ���� T5
% �Ҷ�ƽ�� T6
% �ݶ�ƽ�� T7
% �ҶȾ����� T8
% �ݶȾ����� T9
% ��� T10
% �Ҷ��� T11
% �ݶ��� T12
% ����� T13
% ���� T14
% ���� T15


IMG=imread('E:\MATLAB\contest\bow11\images\training\tea\tea001.bmp');
%  figure, imshow(IMG);
gray=256;

[R,C]=size(IMG);

%����ƽ����ͼ����ݶȾ���
GM=zeros(R-1,C-1);
for i=1:R-1
    for j=1:C-1
        n_GM=(IMG(i,j+1)-IMG(i,j))^2+(IMG(i+1,j)-IMG(i,j))^2;
        GM(i,j)=sqrt(double(n_GM));
    end
end
% figure,imshow(GM);

%�ҳ����ֵ��Сֵ        
n_min=min(GM(:));
n_max=max(GM(:));
%���ݶ�ͼ��Ҷȼ���ɢ��
%�����µĻҶȼ�Ϊnew_gray
new_gray=32;

%�µ��ݶȾ���Ϊnew_GM
new_GM=zeros(R-1,C-1);
new_GM=uint8((GM-n_min)/(n_max-n_min)*(new_gray-1));

%����Ҷ��ݶȹ�������
%�ݶȾ���ȹ�Ⱦ���ά����1�����ԻҶȾ�������Χ
H=zeros(gray,new_gray);
for i=1:R-1
    for j=1:C-1
        H(IMG(i,j)+1,new_GM(i,j)+1)= H(IMG(i,j)+1,new_GM(i,j)+1)+1;
    end
end

%��һ���Ҷ��ݶȾ��� H_basic
total=i*j;
H_basic=H/total;
%С�ݶ����� T1
TT=sum(H);
T1=0;
for j=1:new_gray
    T1=T1+TT(1,j)/j^2;
end
T1=T1/total;
%������ݶ����� T2
T2=0;
for j=1:new_gray
    T2=T2+TT(1,j)*(j-1);
end
T2=T2/total;
%����Ҷȷֲ��Ĳ������� T3
T3=0;
TT1=sum(H');
for j=1:gray
    T3=T3+TT1(1,j)^2;
end
T3=T3/total;
%�����ݶȷֲ��Ĳ������� T4
T4=0;
for j=1:new_gray
    T4=T4+TT(1,j)^2;
end
T4=T4/total;
%�������� T5
T5=0;
for i=1:gray
    for j=1:new_gray
        T5=T5+H_basic(i,j)^2;
    end
end
%����Ҷ�ƽ�� T6
TT2=sum((H_basic)');
T6=0;
for j=1:gray
    T6=T6+(j-1)*TT2(1,j);
end
%�����ݶ�ƽ�� T7
T7=0;
TT3=sum(H_basic);
for j=1:new_gray
    T7=T7+(j-1)*TT3(1,j);
end
%����ҶȾ����� T8
T8=0;
for j=1:gray
    T8=T8+(j-1-T6)^2*TT2(1,j);
end
T8=sqrt(T8);
%�����ݶȾ����� T9
T9=0;
for j=1:new_gray
    T9=T9+(j-1-T7)^2*TT3(1,j);
end
T9=sqrt(T9);
% ������� T10
T10=0;
for i=1:gray
    for j=1:new_gray
        T10=T10+(i-1-T6)*(j-1-T7)*H_basic(i,j);
    end
end
%����Ҷ��� T11
T11=0;
for j=1:gray
    T11=T11+TT2(1,j)*log10(TT2(1,j)+eps);
end
T11=-T11;
%�����ݶ��� T12
T12=0;
for j=1:new_gray
    T12=T12+TT3(1,j)*log10(TT3(1,j)+eps);
end
T12=-T12;
%�������� T13
T13=0;
for i=1:gray
    for j=1:new_gray
        T13=T13+H_basic(i,j)*log10(H_basic(i,j)+eps);
    end
end
T13=-T13;
%������� T14
T14=0;
for i=1:gray
    for j=1:new_gray
        T14=T14+(i-j)^2*H_basic(i,j);
    end
end
%�������� T15
T15=0;
for i=1:gray
    for j=1:new_gray
        T15=T15+H_basic(i,j)/(1+(i-j)^2);
    end
end

x=1:50:750;

OUT(1,1)=T1;
OUT(1,2)=T2;
OUT(1,3)=T3;
OUT(1,4)=T4;
OUT(1,5)=T5;
OUT(1,6)=T6;
OUT(1,7)=T7;
OUT(1,8)=T8;
OUT(1,9)=T9;
OUT(1,10)=T10;
OUT(1,11)=T11;
OUT(1,12)=T12;
OUT(1,13)=T13;
OUT(1,14)=T14;
OUT(1,15)=T15;
% if num>2
%     plot(x,OUT,'-');
%     hold on;
% else
%     plot(x,OUT,'-*r');
%     hold on;
% end

