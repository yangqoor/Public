%最大后验准则前视成像
% author：王震
% time：2016-12-7
clc;
clear all;
close all;

%%  仿回波数据 产生单点目标回波
disp('仿回波数据 产生点目标回波');
%参数定义
A=4*pi/180;          %方位向波束宽度，弧度
L=0.0176348499;        %波长
Tp=10e-6;              %脉宽
B=80e6;                %带宽
fs=120e6;              %采样率
PRF=500;               %重频
PRT=1/PRF;             %脉冲重复周期
v=65;                  %飞机速度
c=299792458;           %光速
C = 299792458;     
aziangle =-20:0.1:20;% 共80的CPI，一个CPI一个Prt
theta = aziangle/180*pi;
CpiNum = length(theta);% CPI 个数

d = 0.009/3;%通道1、2的间距,阵元间距为0.5倍波长
R = 7000;%目标点到通道1、2的间距，设目标在通道1、2中间
% R1 = 6000;
Rn =7185; %sqrt(R^2+(50*d)^2);%目标1斜距
Rn2 = 7080;%R/(cos(8/180*pi));%目标2斜距
Rn3 =7080 ;%R/(cos(8/180*pi));%目标3斜距
Rn4 = 7280;%R1/(cos(11/180*pi));%目标4斜距
Rn5 = 7280;%R1/(cos(11/180*pi));%目标5斜距
fc=c/L;%载频
Kr=B/Tp;  %调频系数
Rmin = 6621;
tmin=2*6621/c-Tp/2;
tmax=2*7680/c+Tp/2;
dt=1/fs;
tr=tmin:dt:tmax;
Nt=length(tr);

Sr1=zeros(CpiNum,Nt);
Sr2=zeros(CpiNum,Nt);

%% 构造方向图
% 方向图函数
thetaB =atan(50*d/(2*Rn));%波束最大指向角
theta1 =1/180*pi;%波束最大指向角
theta2 =-1/180*pi;%波束最大指向角
theta3 =-5/180*pi;%波束最大指向角
F11= zeros(100,CpiNum);
F22= zeros(100,CpiNum);
F11n2= zeros(100,CpiNum);
F22n2= zeros(100,CpiNum);
F11n3= zeros(100,CpiNum);
F22n3= zeros(100,CpiNum);
% 设每个通道100个阵元
for k =1:100
F11(k,:) = exp(1j*k*(2*pi/L)*d*(sin(theta)-sin(thetaB)));%通道1的方向图
end
F1 = sum(F11);

for k=1:100
F22 (k,:)= exp(1j*k*(2*pi/L)*d*(sin(theta)-sin(-thetaB)));%通道2的方向图
end 
F2 = sum(F22);
FSum = (F1)+(F2);%和通道方向图
FSumabs = abs(F1)+abs(F2);%和通道方向图
% 设每个通道100个阵元
for k =1:100
F11n2(k,:) = exp(1j*k*(2*pi/L)*d*(sin(theta+theta1)-sin(thetaB)));%通道1的方向图
end
F1n2 = sum(F11n2);

for k=1:100
F22n2 (k,:)= exp(1j*k*(2*pi/L)*d*(sin(theta+theta1)-sin(thetaB)));%通道2的方向图
end 
F2n2 = sum(F22n2);
FSumn2 = abs(F1n2)+abs(F2n2);%和通道方向图


% 设每个通道100个阵元
for k =1:100
F11n3(k,:) = exp(1j*k*(2*pi/L)*d*(sin(theta+theta2)-sin(thetaB)));%通道1的方向图
end
F1n3 = sum(F11n3);

for k=1:100
F22n3 (k,:)= exp(1j*k*(2*pi/L)*d*(sin(theta+theta2)-sin(thetaB)));%通道2的方向图
end 
F2n3 = sum(F22n3);
FSumn3 = abs(F1n3)+abs(F2n3);%和通道方向图

% 设每个通道100个阵元
F11n4= zeros(100,CpiNum);
F22n4= zeros(100,CpiNum);
for k =1:100
F11n4(k,:) = exp(1j*k*(2*pi/L)*d*(sin(theta+theta3)-sin(thetaB)));%通道1的方向图
end
F1n4 = sum(F11n4);

for k=1:100
F22n4(k,:)= exp(1j*k*(2*pi/L)*d*(sin(theta+theta3)-sin(thetaB)));%通道2的方向图
end 
F2n4 = sum(F22n4);
FSumn4 = abs(F1n4)+abs(F2n4);%和通道方向图

F1db = 20*log10(abs(F1)./max(abs(F1)));
F2db = 20*log10(abs(F2)./max(abs(F2)));
FSumdb = 20*log10(abs(FSum)./max(abs(FSum)));

figure(1);
subplot(2,1,1);
plot(aziangle,F1db);
xlabel('方位角（°）');
ylabel('归一化（dB）')
title('通道1天线方向图归一化图');

subplot(2,1,2);
plot(aziangle,F2db);
xlabel('方位角（°）');
ylabel('归一化（dB）')
title('通道2天线方向图归一化图');

figure(2);
plot(aziangle,FSumdb);
xlabel('方位角（°）');
ylabel('归一化（dB）')
legend('和通道归一化方向图');
%% 构造和通道的数据
yy = exp(-1i*4*pi*Rn/L+1i*pi*Kr*(tr-2*Rn/c).^2).*(abs(tr-2*Rn/c)<Tp/2);
for i=1:CpiNum
    for j=1:2
        Sr1(i,:)=FSumabs(i).*(exp(-1i*4*pi*Rn/L+1i*pi*Kr*(tr-2*Rn/c).^2).*(abs(tr-2*Rn/c)<Tp/2))+...
            FSumn2(i).*(exp(-1i*4*pi*Rn2/L+1i*pi*Kr*(tr-2*Rn2/c).^2).*(abs(tr-2*Rn2/c)<Tp/2))+...
            FSumn4(i).*(exp(-1i*4*pi*Rn2/L+1i*pi*Kr*(tr-2*Rn2/c).^2).*(abs(tr-2*Rn2/c)<Tp/2))+...
            FSumn3(i).*(exp(-1i*4*pi*Rn3/L+1i*pi*Kr*(tr-2*Rn3/c).^2).*(abs(tr-2*Rn3/c)<Tp/2))+...
            FSumn2(i).*(exp(-1i*4*pi*Rn3/L+1i*pi*Kr*(tr-2*Rn4/c).^2).*(abs(tr-2*Rn4/c)<Tp/2))+...
            FSumn3(i).*(exp(-1i*4*pi*Rn5/L+1i*pi*Kr*(tr-2*Rn5/c).^2).*(abs(tr-2*Rn5/c)<Tp/2));
%         Sr1(i,:)=FSum(i).*(exp(-1i*4*pi*Rn/L+1i*pi*Kr*(tr-2*Rn/c).^2).*(abs(tr-2*Rn/c)<Tp/2))+...
%             FSumn2(i).*(exp(-1i*4*pi*Rn2/L+1i*pi*Kr*(tr-2*Rn2/c).^2).*(abs(tr-2*Rn2/c)<Tp/2))+...
%             FSumn3(i).*(exp(-1i*4*pi*Rn5/L+1i*pi*Kr*(tr-2*Rn5/c).^2).*(abs(tr-2*Rn5/c)<Tp/2));
%         Sr1(i,:)=FSum(i).*(exp(-1i*4*pi*Rn/L+1i*pi*Kr*(tr-2*Rn/c).^2).*(abs(tr-2*Rn/c)<Tp/2))+...
%             FSumn2(i).*(exp(-1i*4*pi*Rn2/L+1i*pi*Kr*(tr-2*Rn2/c).^2).*(abs(tr-2*Rn2/c)<Tp/2));
%         Sr1(i,:)=FSumabs(i).*(exp(-1i*4*pi*Rn/L+1i*pi*Kr*(tr-2*Rn/c).^2).*(abs(tr-2*Rn/c)<Tp/2));
    end
end
%% 对信号添加复高斯白噪声噪声
% for k =1:CpiNum
% Sr1(k,:) = awgn(Sr2(k,:),-11);
% end
% Sr2 = wgn(CpiNum,Nt,0);
% Sr1 = Sr1+Sr2;

Sr1 = awgn(Sr1,5,'measured');

% SNR = -5;
% for k = 1:CpiNum
% NOISE=randn(size(Sr2(k,:)));
% NOISE=NOISE-mean(NOISE);
% signal_power = 1/length(Sr2(k,:))*sum(Sr2(k,:).*Sr2(k,:));
% noise_variance = signal_power / ( 10^(SNR/10) );
% NOISE=sqrt(noise_variance)/std(NOISE)*NOISE;
% Sr1(k,:)=Sr2(k,:)+NOISE;
% end

%%
figure(3);
imagesc(real(Sr1));colormap gray;%回波信号(实部)灰度图
xlabel('距离向/m');ylabel('方位向/m');
title('和通道回波信号实部的灰度图');

% FidWrite1= fopen('E:\matlabfile\graduatefile\实波束基于最大后验准则超分辨算法matlab\SimulateDataSum.bin','w');%生成仿真数据文件
FidWrite1= fopen('.\SimulateDataSum.bin','w');%生成仿真数据文件

SrSumData=zeros(1,2*Nt);
% 构造和通道数据
for k = 1:CpiNum
SrSumData(1:2:end) = real(Sr1(k,:));
SrSumData(2:2:end) = imag(Sr1(k,:));
fwrite(FidWrite1,SrSumData,'float32')
end
fclose all;
%% 成像参数
Na =1;
Nr =Nt;
Prf = PRF;
Fs = fs;
Br = B;
NrNew = 1024;
ku = -12;
kv = 18;
N = 1;
yaxis = tr*C/2;
xaxis =aziangle(1):(aziangle(CpiNum)-aziangle(1))/(CpiNum*N-1):aziangle(CpiNum) ;
%% 读取和路数据
disp('读取和路、差路数据')
% FolderImageOutPut = 'E:\matlabfile\graduatefile\实波束基于最大后验准则超分辨算法matlab\';
FolderImageOutPut = '.\';
FidReadSum = fopen([FolderImageOutPut 'SimulateDataSum.bin'],'r');
FidReadReal = fopen('EcholRealSum.dat','w');
FidReadImag = fopen('EcholImagSum.dat','w');

dataline = zeros(CpiNum,Nr);
for k = 1:CpiNum
   DataSum = fread(FidReadSum,Nr*2,'float32');
   dataline(k,:) = DataSum(1:2:2*Nr)+1j*DataSum(2:2:2*Nr);
   fwrite(FidReadReal,DataSum(1:2:end),'float32');
   fwrite(FidReadImag,DataSum(2:2:end),'float32');
end
fclose all;
figure(4);
imagesc(abs(dataline)),colormap gray;
title('原始数据灰度图');
xlabel('距离向');
ylabel('方位向');
%%  距离向脉压
disp('距离向脉压')
StepRanCompSum;

FidReadReal = fopen('RanCompRealSum.dat','r');
FidReadImag= fopen('RanCompImagSum.dat','r');


Y = zeros(NrNew,CpiNum);
for k = 1:CpiNum
    YReal = fread(FidReadReal,NrNew,'float32');
    YImag = fread(FidReadImag,NrNew,'float32');
    Y(:,k) = YReal +1j*YImag;
end
figure;
imagesc(xaxis,yaxis,abs(Y)),colormap hot;
title ('脉压后灰度图');
xlabel('方位角 X(°)');
ylabel('距离向 Y(m)');



%% 形成矩阵 方向图矩阵
FSum1 =(FSumabs);
Mnum =CpiNum+CpiNum-1;
Nnum = CpiNum;
F1A = zeros (Mnum,Nnum);
for k= 1:Nnum
    for j=1:Mnum
        if (j<k)||(k+CpiNum-1<j)
            F1A(j,k)=0;
        else 
            F1A(j,k)=(FSum1(j-k+1));
        end       
    end
end
%% 迭代计算1
FSum2 = fliplr(FSum1);
m =100;%迭代次数;
lamda = 2;
q =2;
rou = 1/lamda;
miu =150;
A =(1+rou*miu)^(-q);
XX = zeros(NrNew,CpiNum);
for k =1:NrNew
    sigma = Y(k,:);
    %% 迭代计算
    for j =1: m  
        fenmu = ifft(fft(FSum1).*fft(sigma));%卷积
        %确保fenmu中无0
        for l =1:CpiNum
            if fenmu(l) == 0
                fenmu(l) =0.001;
            end
        end      
        fenshi1 =(Y(k,:)./fenmu);%相除
        fenshi =ifft(fft((FSum2)).*fft(fenshi1))*rou-rou-log(sigma);%卷积
        sigma_end =sigma.*((fenshi).^q)*A;%相乘
        sigma = sigma_end;
    end   
    XX(k,:) = fftshift(sigma_end);
end
%%
figure;
Ynum = ceil(1.5/39.5*CpiNum);
XX0=circshift(XX,[0 -Ynum]);   
imagesc(xaxis,yaxis,abs(XX)),colormap hot;
title ('基于最大后验准则迭代去卷积算法仿真结果');
xlabel('方位角 X（°）');
ylabel('距离向 Y（m）');
fclose all;


figure;
subplot(2,1,1);
plot(xaxis,abs(Sr1(:,370))/abs(max(Sr1(:,370))));
grid on;
xlabel('方位角（°）')
ylabel('幅值')
title('实波束扫描后剖面图');
subplot(2,1,2);
plot(xaxis,abs(XX(370,:))/abs(max(XX(370,:))),'r');
grid on;
xlabel('方位角（°）')
ylabel('幅值')
title('基于最大后验准则迭代去卷积后剖面图')
%% 
figure;
plot(xaxis,20*log10(abs(Y(454,:))/abs(max(Y(454,:)))));
xlabel('方位角（°）')
ylabel('幅值')
title('实波束扫描点目标-3dB宽度')
figure;
plot(xaxis,20*log10(abs(XX(454,:)/abs(max(XX(454,:))))),'r');
grid on;
xlabel('方位角（°）')
ylabel('幅值')
title('基于最大后验准则迭代去卷积后-3dB宽度')

%% 生成点.raw文件

FidWriteReal = fopen('EndProcessDataReal.dat','w');
FidWriteImag = fopen('EndProcessDataImag.dat','w');
for k = 1:NrNew
DataReal = real(XX(k,:));
DataImag = imag(XX(k,:));
fwrite(FidWriteReal,DataReal,'float32');
fwrite(FidWriteImag,DataImag,'float32');
end

ResultDisplayRaw('EndProcessDataReal.dat','EndProcessDataImag.dat',[FolderImageOutPut '最大后验准则.raw'],NrNew,CpiNum);



%% 由于y数组大小为NrNew个，需要进行插值到CpiNum+CpiNum-1大小
% 
% X0 =18.5:0.25:58;
X0 = linspace(18.5,58,401);
YY = zeros(Mnum,NrNew);
X01 = 18.5:(39.5/(Mnum-1)):58;
for k =1:NrNew
    YY(:,k) = interp1(X0,Y(k,:),X01,'linear');
end

%%  迭代计算2
m =3;%迭代次数;
q = 3;
XX = zeros(NrNew,CpiNum);
for k =1:NrNew
    k
    sigma = Y(k,:)';
    %% 迭代计算
    for j =1: m  
        fenmu = F1A*sigma;
        fenshi1 =(YY(:,k)./fenmu);
        fenshi =(F1A')*fenshi1;
        sigma_end =sigma.*((fenshi).^q);
        sigma = sigma_end;
    end   
    XX(k,:) = (sigma_end);
end


%%
figure;
imagesc(xaxis,yaxis,abs(XX)),colormap gray;

title ('实波束基于最大似然准则超分辨算法仿真数据仿真图');
xlabel('方位角 X(°)');
ylabel('距离向 Y(m)');
fclose all;

% 
