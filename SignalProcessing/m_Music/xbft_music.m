clc
clear 
close all

N=16;
lamda=1;
d=0.5*lamda;

%%%---music�㷨  ������Դ------%%

w=[pi/6 pi/10 pi/8]';%�ź�Ƶ�� 
xx=0*pi/4;yy=-pi/3;zz=pi/90; %�����źŵ������,��Դ��С�ڶȾ����Ա����
N_x=1024; % Length of Signal 
K=0:N-1;
B=[exp(-1i*pi*K'*sin(xx)) exp(-1i*pi*K'*sin(yy)) exp(-1i*pi*K'*sin(zz))] ; %��������,�ź�Դ������������Ԫ���������������������ɣ�
snr=1;
a=sqrt(10^(snr/10));
xxx=a*exp(1i*w*(0:N_x-1));%�����ź�
x=B*xxx+randn(N,N_x)+1j*randn(N,N_x); %������
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
theta=-90:0.1:90;%ULA���ƽǶȱ仯�ķ�Χ��Ƶ��ѡ��
for i = 1:length(theta)
AA=exp(1i*pi*K*sin(theta(i)*pi/180));%����ʸ��
B=eye(size(R))-UU*UU';
WW=AA*(eye(size(R))-UU*UU')*AA';%eye(size(R)������Rһ����С�ĵ�λ����Ȼ���ȥ�ź��ӿռ伴�������ӿռ�
Pmusic(i)=abs(1/WW);%����
end
figure
Pmusic = 20*log10(Pmusic);
sita=-90:0.1:90;
plot(sita,Pmusic);
grid
xlabel('�����ź�Դ') 

%%%----�����γ�---%%

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
plot(theta,p,'r--','linewidth',2);%theta������������ͼ
text(theta(160),-3,['(N=8:ָ��\theta=' num2str(theta1) '\circ3dB����'  num2str(HPBW)  ')']); 
axis([0 180 -50 0]);

