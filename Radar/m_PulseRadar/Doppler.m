clear all;
close all;
clc;
%%定义参数
N=4096;  %信号的采样个数
fs=1e8   %采样率Hz
t=(0:N-1)/fs;   %仿真时间
f0=10e9;   %载频频率Hz
Tp=10e-6;   %脉冲宽度s
b=1e12 %线性调频率
tao=2e-5
Tr=100e-6   %脉冲重复周期
M=64    %脉冲总个数
v=60    %速度
R0=3000 %距离
c=3e8   %光速

%%构造回波信号 S

S=zeros(M,N);
Sn=zeros(M,N);
FFT_S=zeros(M,N);
Spetrum_FIN=zeros(M,N);
Spetrum1=zeros(M,N);
Spetrum2=zeros(M,N);
Spetrum3=zeros(M,N);
gonge=zeros(M,N);
Spetrum_lie=zeros(M,N);
fft_Num=4096;


%%脉压
for m=1:M

taom=2*(R0-m*Tr*v)/c;
S(m,:)=rectpuls(t-Tp/2-taom,Tp).*exp(1j*pi*b*(t-Tp/2-taom).^2).*exp(-2j*pi*f0*taom);%回波信号
%%回波频谱分析
Sn(m,:)=rectpuls(t-Tp/2,Tp).*exp(j*pi*b*(t-Tp/2).^2);%参考信号
Spetrum2(m,:)=fftshift(fft(Sn(m,:),fft_Num));
Spetrum1(m,:)=fftshift(fft(S(m,:),fft_Num));
gonge(m,:)=conj(Spetrum2(m,:)) ;   %共轭相乘
result(m,:)=gonge(m,:).*Spetrum1(m,:);
Spetrum_FIN(m,:)=ifft(result(m,:));

end
figure(1);



title('距离像脉冲压缩后图像');
xlabel('距离，单位m');
ylabel('速度  m/s');

R=t.*c/2
imagesc(R,1:M,abs(Spetrum_FIN));
%%方向性FFT
Spetrum_lie=zeros(M,N);
for i2=1:N
    Spetrum_lie(:,i2)=fftshift(fft(Spetrum_FIN(:,i2),M));
end
figure(2);
datv=1/(2*Tr*M)*c/f0*(-M/2:M/2-1)
imagesc(R,datv,abs( Spetrum_lie));

[L,W]=find (abs(Spetrum_lie)==max(max(abs(Spetrum_lie))))%返回最大值所在的行和列

%sprint('距离速度为：3000m，60m/s')

title('二维距离多普勒平面')
xlabel('距离，单位m');
ylabel('速度  m/s');
datv(L)
R(W)