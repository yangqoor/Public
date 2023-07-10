clear all
%第一步：性能指标转换
Wp1=200*2*pi;%通带截止角频率
Wp2=300*2*pi;%通带截止角频率
Wst1=150*2*pi;%阻带截止角频率
Wst2=350*2*pi;%阻带截止角频率
det1=3;%通带最大衰减
det2=20;%阻带最小衰减
Fs=1000;%采样频率
%性能指标修正（参看双线性变换法优缺点中的频率预畸变）
Wp1=Fs*2*tan(Wp1/Fs/2);%通带截止角频率
Wp2=Fs*2*tan(Wp2/Fs/2);%通带截止角频率
Wst1=Fs*2*tan(Wst1/Fs/2);%阻带截止角频率
Wst2=Fs*2*tan(Wst2/Fs/2);%阻带截止角频率
W0=sqrt(Wp1*Wp2);
B=Wp2-Wp1;
%将带通性能指标转化为低通性能指标
Wp=B;
Wst=min(abs((Wst1^2-W0^2)/Wst1),abs((Wst2^2-W0^2)/Wst2));

%第二步：把低通性能指标代入巴特沃斯模型计算出归一化模拟低通滤波器
[N,Wc]=buttord(Wp,Wst,det1,det2,'s');%将性能指标代入巴特沃斯模型，计算出滤波器阶数N和3dB截止角频率
[Z,P,K]=buttap(N);%计算阶数为N的截止角频率为1巴特沃斯滤波器系统函数，得到的是零极点模型
[Bap,Aap]=zp2tf(Z,P,K);%将截止角频率为1的零极点模型转换为多项式模型

%第三步：将归一化模拟低通滤波器转换为带通滤波器
[bx,ax]=lp2bp(Bap,Aap,W0,B);

%第四步：根据采样频率，利用冲激响应不变法或双线性变换法，将模拟滤波器转化为数字滤波器 
% [bz,az]=impinvar(bx,ax,Fs);
[bz,az]=bilinear(bx,ax,Fs);

%第五步：画出设计好的滤波器的幅度响应，检验是否满足要求
[H,W]=freqz(bz,az);
figure
plot(W*Fs/(2*pi),abs(H),'k');
grid
xlabel('频率/Hz');
ylabel('幅度响应');