% 低斜视角情况
%CSA机载情况下的仿真程序
clear,clc,close all;
c = 3e8;
pi = 3.1415926;
j = sqrt(-1);
fc = 5.3e9;%雷达工作频率
lamda = c/fc;

%测绘带参数
theta = 2/180*pi; %波束斜视角
R0_cen = 20e3;%景中心到天线距离
R0=R0_cen*cos(theta);%景中心对应的斜距

%距离向参数
Tr = 2.5e-6;%发射脉冲时宽
Bw =50e6;%带宽
Kr = Bw/Tr;%调频率
alpha =3.4; %距离向过采样系数
Fr = alpha*Bw;%采样率
%方位向参数
Vr = 150;%雷达有效速度
La = 3.75;  %天线方位向长度
dopBw = 2*Vr*cos(theta)/La;%多普勒带宽4.36
beta = 2.5;%方位向过采样率，
PRF = beta*dopBw;%4.36下面
Ka = 2*Vr.^2*(cos(theta)).^3/lamda/R0;%方位向调频率式4.38
Ts = dopBw/abs(Ka);%目标照射时间，多普勒带宽=目标照射时间*方位向调频率
Ls = Vr*Ts; %合成孔径长度
f_eta_c = 2*Vr*sin(theta)/lamda;%多普勒中心频率式4.33
f_eta_ref=f_eta_c;%参考目标的多普勒中心频率
beita_bw=0.886*lamda/La;%用来计算方位向方向性函数

R_ref=R0;%参考斜距为R_ref
x1=R0;
y1=R0*tan(theta);%将波束中心照射目标一时的时间定义为方位向时间起点
x2=x1+50;
y2=y1+100;
x3=x2+100;
y3=y2+100*tan(theta);
%将位置写成矩阵形式，方便后面调用
x=[x1 x2 x3];
y=[y1 y2 y3];
deltaX=max(x)-min(x);
deltaY=max(y)-min(y);

%三个目标各自的波束中心穿越时刻
eta_c=[(y1-x1*tan(theta))/Vr (y2-x2*tan(theta))/Vr (y3-x3*tan(theta))/Vr];
%距离向时间序列
Nr=2^nextpow2((2*(deltaX)/c+Tr)*Fr);%采样窗的点数向上取到2的幂次，方便计算fft
tau=2*R0/c+linspace(-Nr/2/Fr,Nr/2/Fr,Nr);
f_tau=linspace(-Fr/2,Fr/2,Nr);
dr=c/2.*tau;
Na=2^nextpow2((deltaY+2*Ls)/Vr*PRF);
t_eta=linspace(-Na/2/PRF,Na/2/PRF,Na);
f_eta=f_eta_c+linspace(-PRF/2,PRF/2,Na);
% 生成距离（方位）时间（频率）矩阵,行是距离向，列是方位向
tau2=ones(Na,1)*tau;
f_tau2=ones(Na,1)*f_tau;
t_eta2=t_eta'*ones(1,Nr);
f_eta2=f_eta'*ones(1,Nr);

echo=zeros(Na,Nr); % 用来存放生成的回波数据
A=[1 1 1];%散射系数
for i=1:3
    Rn=sqrt((x(i).*ones(Na,Nr)).^2 +(Vr.*t_eta2-y(i).*ones(Na,Nr)) .^2  );% 目标i的瞬时斜距
    wr=(abs(tau2-2.*Rn./c))<=((Tr/2).*ones(Na,Nr));% 距离向包络，即距离窗
    theta_wa=atan(Vr.*(t_eta2-eta_c(i).*ones(Na,Nr))/x(i));
    wa=(sinc(theta_wa./beita_bw)).^2;% 方位向包络，也就是 天线的双程方向图作用因子。(4.28以及4.31)
   echo=  echo+A(i).*wr.*wa.*exp(-j*4*pi/lamda.*Rn).*exp(j*pi*Kr.*(tau2-2.*Rn./c).^2);%(6.1)
end
    
figure;subplot(2,2,1);imagesc(real(echo));title('（a）实部');xlabel('距离时域（采样点）');ylabel('方位时域（采样点）');
subplot(2,2,2);imagesc(imag(echo));title('（b）虚部');xlabel('距离时域（采样点）');ylabel('方位时域（采样点）');
subplot(2,2,3);imagesc(abs(echo));title('（c）幅度');xlabel('距离时域（采样点）');ylabel('方位时域（采样点）');
subplot(2,2,4);imagesc(angle(echo));title('（d）相位');xlabel('距离时域（采样点）');ylabel('方位时域（采样点）');
title('原始数据');
a1=abs(fftshift(fft(fftshift(echo))));
a2=angle(fftshift(fft(fftshift(echo))));
a3=abs(fftshift(fft2(fftshift(echo))));
a4=angle(fftshift(fft2(fftshift(echo))));
figure;subplot(2,2,1);imagesc(a1);title('RD 频谱幅度');
subplot(2,2,2);imagesc(a2);title('RD 频谱相位');
subplot(2,2,3);imagesc(a3);title('二维频谱幅度');
subplot(2,2,4);imagesc(a4);title('二维频谱相位');

srd=echo.*exp(-j*2*pi*f_eta_c.*t_eta2);% 频谱搬移到0位置
Srd=fftshift(fft(fftshift(srd)));% 进行方位向傅里叶变换，得到距离多普勒域频谱
figure;
imagesc(abs(Srd));
title('原始数据变换到距离多普勒域，幅度');

D_f=sqrt(1-lamda^2.*(f_eta').^2/(4*Vr^2));%(7.17) 徙动因子，列向量
D_f_eta=D_f*ones(1,Nr);% 形成矩阵，大小：Na*Nr
D_f_eta_ref=sqrt(1-lamda^2*f_eta_ref^2/(4*Vr^2));
km_yin=2*Vr^2*fc^3.*D_f.^3./(c*R_ref*(f_eta').^2)*ones(1,Nr);
Km=Kr./(1-Kr./km_yin);%(7.18)矩阵，这是变换到距离多普勒域的距离调频率。
%变标方程 s_sc
s_sc=exp(j*pi*Km.*(D_f_eta_ref./D_f_eta-1).*(tau2-2*R_ref./(c.*D_f_eta)).^2);
% 下面将距离多普勒域的信号与变标方程相乘，实现“补余RCMC”
S1=Srd.*s_sc;

figure;imagesc(abs(S1));
title('距离多普勒域，补余RCMC后，幅度');
 % 进行距离向FFT，变换到二维频域。距离零频在两端
S2=fftshift(fft(fftshift(S1),[],2));
figure;imagesc(abs(S2));
title('变换到二维频域');
% 完成距离压缩，SRC，一致RCMC这三者相位补偿的滤波器为：
s_sc2=exp(j*pi.*D_f_eta./(D_f_eta_ref.*Km).*f_tau2.^2)...
    .*exp(j*4*pi/c*(1./D_f_eta-1/D_f_eta_ref).*R_ref.*f_tau2);
S3=S2.*s_sc2;	% 在二维频域，相位相乘，实现距离压缩，SRC，一致RCMC
figure;imagesc(abs(S3));
title('相位相乘，实现距离压缩，SRC，一致RCMC后，二维频域');
S4 = ifftshift(ifft(ifftshift(S3),[],2));  
figure;imagesc(abs(S4));title('完成距离压缩，SRC，一致RCMC后，距离多普勒域');

H=exp(j*4*pi*fc.*(D_f*dr)./c);% 生成方位向匹配滤波器
H2=exp(-j*4*pi.*Km/c^2.*(1-D_f_eta./D_f_eta_ref));  % 附加相位校正项
% 下面进行相位相乘，在距离多普勒域，同时完成方位MF和附加相位校正
S5=S4.*H.*H2;  % 距离多普勒域，相位相乘
figure;
imagesc(abs(S5));
title('距离多普勒域，进行了相位相乘后（方位MF和附加相位校正）');
s=fftshift(ifft(fftshift(S5)));
figure;
imagesc(abs(s));
title('成像结果');
