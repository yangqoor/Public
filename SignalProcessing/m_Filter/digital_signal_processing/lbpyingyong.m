%问题：已知某传感器测量到得物理信号为x(t)=20*sin(25*2*pi*t+pi/3)+15*sin(200*2*pi*t+pi/2)+10*sin(220*2*pi*t+pi/2)+8*sin(240*2*pi*t+pi/2),其中20*sin(25*2*pi*t
%+pi/3)为有用信号，其余为干扰信号。传感器测量时间为t=4秒，采样频率为500Hz，请设计一个数字滤波器，滤除干扰信号，求出滤波后的信号。

%第一步：确定性能指标，并设计数字滤波器
Wp=100*2*pi;%通带截止角频率
Wst=200*2*pi;%阻带截止角频率
det1=2;%通带最大衰减
det2=15;%阻带最小衰减
Fs=500;
%性能指标修正
% Wp=Fs*2*tan(Wp/Fs/2);%通带截止角频率
% Wst=Fs*2*tan(Wst/Fs/2);%阻带截止角频率

[N,Wc]=buttord(Wp,Wst,det1,det2,'s');%将性能指标代入巴特沃斯模型，计算出滤波器阶数N和3dB截止角频率
[Z,P,K]=buttap(N);%计算阶数为N的截止角频率为1巴特沃斯滤波器系统函数，得到的是零极点模型
[Bap,Aap]=zp2tf(Z,P,K);%将截止角频率为1的零极点模型转换为多项式模型
[b,a]=lp2lp(Bap,Aap,Wc);%将将截止角频率为1的传递函数转化为我们所需要的截止频率为Wc的系统函数

[bz,az]=bilinear(b,a,Fs);%根据采样频率，利用双线性变换法，将模拟低通滤波器转化为数字低通滤波器
[H,W]=freqz(bz,az);

figure
plot(W*Fs/(2*pi),abs(H),'k');%画出设计好的滤波器的幅度响应，检验是否满足要求
grid
xlabel('频率/Hz');
ylabel('幅度响应');

%第二步：计算模拟信号x(t)进过采样后变为数字信号x(n)；
t=4;
Num=t*Fs;
nt=[0:1/Fs:(Num-1)*1/Fs];
Xn=20*sin(25*2*pi*nt+pi/3)+15*sin(200*2*pi*nt+pi/2)+10*sin(220*2*pi*nt+pi/2)+8*sin(240*2*pi*nt+pi/2);
FXn=fft(Xn);%分析数字信号x(n)的频谱；
figure
subplot(2,2,1);
plot(nt(1:200),Xn(1:200),'r-');
xlabel('时间/s');
ylabel('幅度');
grid
title('输入信号x(n)');
subplot(2,2,2);
plot((0:Num/2-1)*(1/t),2*1/Num*abs(FXn(1:Num/2)),'r-');
% plot((0:Num-1)*(1/t),2*1/Num*abs(FXn(1:Num)));
grid
xlabel('频率/Hz');
ylabel('幅度');
title('输入信号频谱X(jw)');

%第三步：将数字信号输入滤波器，计算输出信号Yn
%%%%%%方法一：在时域利用卷积法计算Yn=Xn卷积h(n)；
% [hn,tt]=impz(bz,az,100,Fs);%计算冲击响应h(n)，也可以用hn=filter(bz,az,[1 zeros(1,99)]);
% Yn=conv(Xn,hn');%Xn卷积h(n)的长度为Num+100-1;也可以直接用：Yn=filter(bz,az,Xn);

%%%%%%方法二：利用频域相乘法得到Yn的频谱：FYn=FXn*H(ejw);再对FYn逆傅里叶变换得到Yn
Hh=[H' zeros(1,Num-512)];%也可以用Hh=fft(hn)；
FYn=FXn.*Hh;%频域相乘法得到Yn的频谱FYn;
Yn=ifft(FYn);%对FYn逆傅里叶变换得到Yn

%%%%%%方法三：利用直接一型实现[bz,az]数字滤波器，计算输出信号Yn；
%直接一型[bz,az]数字滤波器:Yn(n)=bz(1)*Xn(n)+bz(2)*Xn(n-1)+bz(3)*Xn(n-2)+bz(4)*Xn(n-3)-(az(2)*Yn(n-1)+az(3)*Yn(n-2)+az(4)*Yn(n-3))
% Yn=zeros(1,Num);
% Yn(1)=bz(1)*Xn(1);
% Yn(2)=bz(1)*Xn(2)+bz(2)*Xn(1)-az(2)*Yn(1);
% Yn(3)=bz(1)*Xn(3)+bz(2)*Xn(2)+bz(3)*Xn(1)-az(2)*Yn(2)-az(3)*Yn(1);
for n=4:2000
    Yn(n)=bz(1)*Xn(n)+bz(2)*Xn(n-1)+bz(3)*Xn(n-2)+bz(4)*Xn(n-3)-(az(2)*Yn(n-1)+az(3)*Yn(n-2)+az(4)*Yn(n-3));
end

subplot(2,2,3);
plot((1:200)/Fs,Yn(1:200),'r');
xlabel('时间/s');
ylabel('幅度');
grid
title('输入信号y(n)');

FYn=fft(Yn);%分析数字信号Yn的频谱；
length=size(Yn,2);
subplot(2,2,4);
plot((0:round(length/2)-1)*1/(length/Fs),2*1/length*abs(FYn(1:round(length/2))),'r');
xlabel('频率/Hz');
ylabel('幅度');
grid
title('输出信号频谱Y(jw)');