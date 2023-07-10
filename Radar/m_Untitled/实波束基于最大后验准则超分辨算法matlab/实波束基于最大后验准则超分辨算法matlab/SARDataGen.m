%%  仿回波数据 产生单点目标回波
if 1
disp('仿回波数据 产生点目标回波');
%参数定义
A=4.2*pi/180;          %方位向波束宽度，弧度
L=0.0176348499;        %波长
Tp=10e-6;              %脉宽
B=80e6;                %带宽
fs=120e6;              %采样率
PRF=500;               %重频
PRT=1/PRF;             %脉冲重复周期
v=65;                 %飞机速度
c=299792458;                 %光速
AziAngle =-18.25:0.1:21.25;% 共80的CPI，一个CPI一个Prt
theta = AziAngle/180*pi;
CipNum = length(theta);% CPI 个数

d = 0.009;%通道1、2的间距,阵元间距为0.5倍波长
R = 7000;%目标点到通道1、2的间距，设目标在通道1、2中间

Rc=6270;
R1=[6275 6278];%点目标的距离向坐标
R2=[6272 6275];%

X1=[0 3];%点目标的方位向坐标
X2=[0 -3];
Ls=Rc*A;%合成孔径长度


%(-Na/2:Na/2-1)'/Prf;            %方位慢时间
n=floor((-5-Ls/2)*PRF/v):ceil((5+Ls/2)*PRF/v);
tn=n/PRF;
xn=tn*v;
Nn=length(n);

Rn1=zeros(Nn,2);
Rn2=zeros(Nn,2);

fn=(-floor(Nn/2):ceil(Nn/2)-1)*PRF/Nn;

fc=c/L;%载频
Kr=B/Tp;  %调频系数
tmin=2*15100/c-Tp/2;
tmax=2*15300/c+Tp/2;
dt=1/fs;
tr=tmin:dt:tmax;
Nt=length(tr);

Sr1=zeros(Nn,Nt);
Sr2=zeros(Nn,Nt);
% 方向图函数
thetaB =atan(50*d/(2*R));%波束最大指向角
F11= zeros(100,396);
F22= zeros(100,396);

% 设每个通道100个阵元
for k =1:100
F11(k,:) = exp(1j*k*(2*pi/L)*d*(sin(theta)-sin(thetaB)));%通道1的方向图
end
F1 = sum(F11);

for k=1:100
F22 (k,:)= exp(1j*k*(2*pi/L)*d*(sin(theta)-sin(-thetaB)));%通道2的方向图
end 
F2 = sum(F22);
FSum = abs(F1)+abs(F2);%和通道方向图
FSub = abs(F1)-abs(F2);%差通道方向图


F1db = 20*log10(abs(F1)./max(abs(F1)));
F2db = 20*log10(abs(F2)./max(abs(F2)));

FSumdb = 20*log10(abs(FSum)./max(abs(FSum)));
FSubdb = 20*log10(abs(FSub)./max(abs(FSub)));

figure(3);
subplot(2,1,1);
plot(AziAngle,F1db);
xlabel('方位角（°）');
ylabel('归一化（dB）')
title('通道1天线方向图归一化图');

subplot(2,1,2);
plot(AziAngle,F2db);
xlabel('方位角（°）');
ylabel('归一化（dB）')
title('通道2天线方向图归一化图');

figure(2);

plot(AziAngle,FSumdb);
xlabel('方位角（°）');
ylabel('归一化（dB）')
hold on;

plot(AziAngle,FSubdb,'r');
hold off;
legend('和通道归一化方向图','方位差通道归一化方向图');



% 构造1通道的数据
for j=1:2
   Rn1(:,j)=sqrt(R1(j)^2+(xn.'-X1(j)).^2);
end
for i=1:CipNum
    for j=1:2
        Sr1(i,:)=Sr1(i,:)+exp(-1i*4*pi*Rn1(i,j)/L+1i*pi*Kr*(tr-2*Rn1(i,j)/c).^2).*(abs(tr-2*Rn1(i,j)/c)<Tp/2).*(abs(xn(i)-X1(j))<Ls/2);%叠加后的回波
    end 
end
figure(1);subplot(211);
imagesc(c*tr/2,xn,real(Sr1));colormap gray;%回波信号(实部)灰度图
xlabel('距离向/m');ylabel('方位向/m');
title('波束1回波信号实部的灰度图');

%构造2通道的数据
for j=1:2
   Rn2(:,j)=sqrt(R2(j)^2+(xn.'-X2(j)).^2);
end
for i=1:CipNum
    for j=1:2
        Sr2(i,:)=Sr2(i,:)+exp(-1i*4*pi*Rn2(i,j)/L+1i*pi*Kr*(tr-2*Rn2(i,j)/c).^2).*(abs(tr-2*Rn2(i,j)/c)<Tp/2).*(abs(xn(i)-X2(j))<Ls/2);%叠加后的回波
    end 
end
subplot(212);
imagesc(c*tr/2,xn,real(Sr2));colormap gray;%回波信号(实部)灰度图
xlabel('距离向/m');ylabel('方位向/m');
title('波束2回波信号实部的灰度图');

SrSumData=zeros(Nn,2*Nt);
SrAziData=zeros(Nn,2*Nt);
% 构造和通道数据
SrSum = Sr1+Sr2;
for k = 1:Nn
SrSumData(k,1:2:end) = real(SrSum(k,:));
SrSumData(k,2:2:end) = imag(SrSum(k,:));
end

% 构造方位差通道数据
SrAzi = Sr1-Sr2;
for k = 1:Nn
SrAziData(k,1:2:end) = real(SrAzi(k,:));
SrAziData(k,2:2:end) = imag(SrAzi(k,:));
end


FidWrite1= fopen('.\SimulateData.bin','w');%生成仿真数据文件
fwrite(FidWrite1,SrSumData,'float32')
fwrite(FidWrite1,SrAziData,'float32')
fclose all;

end