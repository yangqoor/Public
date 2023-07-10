clc
clear 
close all

N=16;
lamda=1;
d=0.5*lamda;

%%%---music算法  三个信源------%%

w=[pi/6 pi/10 pi/8]';%信号频率 
xx=0*pi/4;yy=-pi/3;zz=pi/90; %三个信号的入射角,信源间小于度就难以辨别了
N_x=1024; % Length of Signal 
K=0:N-1;
B=[exp(-1i*pi*K'*sin(xx)) exp(-1i*pi*K'*sin(yy)) exp(-1i*pi*K'*sin(zz))] ; %阵列流型,信号源决定行数，阵元数决定列数？？反过来吧？
snr=1;
a=sqrt(10^(snr/10));
xxx=a*exp(1i*w*(0:N_x-1));%仿真信号
x=B*xxx+randn(N,N_x)+1j*randn(N,N_x); %加噪声
% X=fft(fftshift(x));
% XX=fft(fftshift(X));
% subplot(211);
% plot(abs(XX))
% subplot(212);
% plot(xxx)

R=x*x';
[V,D]=eig(R);
[lambda,index]=sort(diag(D));
UU=V(:,index(N-2:N));
theta=-90:0.1:90;%ULA估计角度变化的范围和频率选择
for i = 1:length(theta)
AA=exp(1i*pi*K*sin(theta(i)*pi/180));%方向矢量
B=eye(size(R))-UU*UU';
WW=AA*(eye(size(R))-UU*UU')*AA';%eye(size(R)返回与R一样大小的单位矩阵，然后减去信号子空间即是噪声子空间
Pmusic(i)=abs(1/WW);%角谱
end
figure
Pmusic = 20*log10(Pmusic);
sita=-90:0.1:90;
plot(sita,Pmusic);
grid
xlabel('三个信号源') 

%%%----波束形成---%%

theta0=60;
inter=0.5;
Btheta=[];p=[];
theta=0:inter:180;
for i=1:length(theta)
    Btheta(i)=sin(N/2*2*pi*d/lamda*(cos(theta(i)*pi/180)-cos(theta0*pi/180)))./sin(1/2*2*pi*d/lamda*(cos(theta(i)*pi/180)-cos(theta0*pi/180)))/N;
    p(i)=10*log(abs(Btheta(i)));
end
[c,b]=max(p);theta1=theta(b)+inter;
i=1;H=[];
for k=1:length(p)
    if (p(k)>c-3)
        H(i)=theta(k);
        i=i+1;
    end
end
HPBW=max(H)-min(H);
theta=0:inter:180;
figure
plot(theta,p,'r--','linewidth',2);%theta参数波束方向图
text(theta(160),-3,['(N=8:指向\theta=' num2str(theta1) '\circ3dB带宽'  num2str(HPBW)  ')']); 
axis([0 180 -50 0]);

