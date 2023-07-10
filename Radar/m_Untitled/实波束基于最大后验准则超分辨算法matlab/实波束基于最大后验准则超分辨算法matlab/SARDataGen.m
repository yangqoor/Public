%%  �»ز����� ��������Ŀ��ز�
if 1
disp('�»ز����� ������Ŀ��ز�');
%��������
A=4.2*pi/180;          %��λ������ȣ�����
L=0.0176348499;        %����
Tp=10e-6;              %����
B=80e6;                %����
fs=120e6;              %������
PRF=500;               %��Ƶ
PRT=1/PRF;             %�����ظ�����
v=65;                 %�ɻ��ٶ�
c=299792458;                 %����
AziAngle =-18.25:0.1:21.25;% ��80��CPI��һ��CPIһ��Prt
theta = AziAngle/180*pi;
CipNum = length(theta);% CPI ����

d = 0.009;%ͨ��1��2�ļ��,��Ԫ���Ϊ0.5������
R = 7000;%Ŀ��㵽ͨ��1��2�ļ�࣬��Ŀ����ͨ��1��2�м�

Rc=6270;
R1=[6275 6278];%��Ŀ��ľ���������
R2=[6272 6275];%

X1=[0 3];%��Ŀ��ķ�λ������
X2=[0 -3];
Ls=Rc*A;%�ϳɿ׾�����


%(-Na/2:Na/2-1)'/Prf;            %��λ��ʱ��
n=floor((-5-Ls/2)*PRF/v):ceil((5+Ls/2)*PRF/v);
tn=n/PRF;
xn=tn*v;
Nn=length(n);

Rn1=zeros(Nn,2);
Rn2=zeros(Nn,2);

fn=(-floor(Nn/2):ceil(Nn/2)-1)*PRF/Nn;

fc=c/L;%��Ƶ
Kr=B/Tp;  %��Ƶϵ��
tmin=2*15100/c-Tp/2;
tmax=2*15300/c+Tp/2;
dt=1/fs;
tr=tmin:dt:tmax;
Nt=length(tr);

Sr1=zeros(Nn,Nt);
Sr2=zeros(Nn,Nt);
% ����ͼ����
thetaB =atan(50*d/(2*R));%�������ָ���
F11= zeros(100,396);
F22= zeros(100,396);

% ��ÿ��ͨ��100����Ԫ
for k =1:100
F11(k,:) = exp(1j*k*(2*pi/L)*d*(sin(theta)-sin(thetaB)));%ͨ��1�ķ���ͼ
end
F1 = sum(F11);

for k=1:100
F22 (k,:)= exp(1j*k*(2*pi/L)*d*(sin(theta)-sin(-thetaB)));%ͨ��2�ķ���ͼ
end 
F2 = sum(F22);
FSum = abs(F1)+abs(F2);%��ͨ������ͼ
FSub = abs(F1)-abs(F2);%��ͨ������ͼ


F1db = 20*log10(abs(F1)./max(abs(F1)));
F2db = 20*log10(abs(F2)./max(abs(F2)));

FSumdb = 20*log10(abs(FSum)./max(abs(FSum)));
FSubdb = 20*log10(abs(FSub)./max(abs(FSub)));

figure(3);
subplot(2,1,1);
plot(AziAngle,F1db);
xlabel('��λ�ǣ��㣩');
ylabel('��һ����dB��')
title('ͨ��1���߷���ͼ��һ��ͼ');

subplot(2,1,2);
plot(AziAngle,F2db);
xlabel('��λ�ǣ��㣩');
ylabel('��һ����dB��')
title('ͨ��2���߷���ͼ��һ��ͼ');

figure(2);

plot(AziAngle,FSumdb);
xlabel('��λ�ǣ��㣩');
ylabel('��һ����dB��')
hold on;

plot(AziAngle,FSubdb,'r');
hold off;
legend('��ͨ����һ������ͼ','��λ��ͨ����һ������ͼ');



% ����1ͨ��������
for j=1:2
   Rn1(:,j)=sqrt(R1(j)^2+(xn.'-X1(j)).^2);
end
for i=1:CipNum
    for j=1:2
        Sr1(i,:)=Sr1(i,:)+exp(-1i*4*pi*Rn1(i,j)/L+1i*pi*Kr*(tr-2*Rn1(i,j)/c).^2).*(abs(tr-2*Rn1(i,j)/c)<Tp/2).*(abs(xn(i)-X1(j))<Ls/2);%���Ӻ�Ļز�
    end 
end
figure(1);subplot(211);
imagesc(c*tr/2,xn,real(Sr1));colormap gray;%�ز��ź�(ʵ��)�Ҷ�ͼ
xlabel('������/m');ylabel('��λ��/m');
title('����1�ز��ź�ʵ���ĻҶ�ͼ');

%����2ͨ��������
for j=1:2
   Rn2(:,j)=sqrt(R2(j)^2+(xn.'-X2(j)).^2);
end
for i=1:CipNum
    for j=1:2
        Sr2(i,:)=Sr2(i,:)+exp(-1i*4*pi*Rn2(i,j)/L+1i*pi*Kr*(tr-2*Rn2(i,j)/c).^2).*(abs(tr-2*Rn2(i,j)/c)<Tp/2).*(abs(xn(i)-X2(j))<Ls/2);%���Ӻ�Ļز�
    end 
end
subplot(212);
imagesc(c*tr/2,xn,real(Sr2));colormap gray;%�ز��ź�(ʵ��)�Ҷ�ͼ
xlabel('������/m');ylabel('��λ��/m');
title('����2�ز��ź�ʵ���ĻҶ�ͼ');

SrSumData=zeros(Nn,2*Nt);
SrAziData=zeros(Nn,2*Nt);
% �����ͨ������
SrSum = Sr1+Sr2;
for k = 1:Nn
SrSumData(k,1:2:end) = real(SrSum(k,:));
SrSumData(k,2:2:end) = imag(SrSum(k,:));
end

% ���췽λ��ͨ������
SrAzi = Sr1-Sr2;
for k = 1:Nn
SrAziData(k,1:2:end) = real(SrAzi(k,:));
SrAziData(k,2:2:end) = imag(SrAzi(k,:));
end


FidWrite1= fopen('.\SimulateData.bin','w');%���ɷ��������ļ�
fwrite(FidWrite1,SrSumData,'float32')
fwrite(FidWrite1,SrAziData,'float32')
fclose all;

end