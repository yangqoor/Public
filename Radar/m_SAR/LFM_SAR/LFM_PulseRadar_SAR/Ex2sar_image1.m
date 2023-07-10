%关闭
close all;
clear all;
clc;

%Q1产生单点目标的回波
Tp = 2e-5;       %脉冲宽度
B  = 7e+7;       %发射信号带宽
fs = 1e+8;       %采样率
Lamda = 0.03125; %载波波长
c = 3e+8;        %光速
Rn = 1.52e+4;    %距离向坐标
Rmin = 1.5e+4;   %初始采样距离
PRF = 700;       %脉冲重复频率
PRT = 1/PRF;     %脉冲重复周期
Kr = B / Tp;     %调频率
fc = c / Lamda;  %载波频率
A = 1.5/180*pi;  %方位向波束宽度
v0 = 100;        %飞机速度
targetX1 = 0;    %点1的方位向坐标
targetX2 = 3;    %点2的方位向坐标
Ls = 2*Rn*tan(A/2);       %合成孔径长度

%发射信号
emit_t = 0:1/fs:Tp;         %发射信号观测时间范围
St_emit = exp(1i*pi*Kr*emit_t.^2);      %发射信号

%nLs = floor(-Ls/(2*PRT*v0)):ceil(Ls/(2*PRT*v0));
x = -Ls/2:PRT*v0:Ls/2;          %平台运动位置
Rnd = sqrt(x.^2 + Rn^2);        %实际的斜距
tnd = 2*Rnd/c;
ND = length(x);

echo_t = 2*Rn/c-Tp/2:1/fs:(max(Rnd)*2/c)+Tp;        %回波观测时间范围,起始时间减去Tp/2为了防止得到距离脉压后的第一个点数据就为峰值，
                                                    %使得画出来的图形只能得到sinc包络的一半
len_echo = length(echo_t);                          %回波的观测点数
echo_d = echo_t.*c/2;
St_back = zeros(ND,len_echo);                 %回波信号矩阵

%目标1
for m = 1 : ND
    St_back(m,:) = rectpuls((echo_t-tnd(m)-Tp/2)/Tp).*exp(1i*pi*Kr*(echo_t-tnd(m)).^2).*exp(1i*2*pi*fc*(-tnd(m)));
end

real_St_back = real(St_back);           %取实部
%回波数据的灰度图
figure(1);
imagesc(echo_d,x,real_St_back); 
colormap(gray);
title('回波数据实部灰度图');
xlabel('距离向坐标/m');
ylabel('方位向坐标/m');

NFFT_D = 2^nextpow2(length(emit_t)+len_echo-1);                     %距离向fft的点数
FSt_emit = fft(St_emit,NFFT_D);                                     %发射信号的FFT
F_filter = conj(FSt_emit);                                          %参考信号的fft，时域取反的共轭，相当于频域取共轭

%距离向脉冲压缩
Dcompressed_signal = zeros(ND,len_echo);
for m = 1 : ND
    FSt_back = fft(St_back(m,:),NFFT_D);
    iFSt_back = ifft(FSt_back.*F_filter);
    Dcompressed_signal(m,:) = iFSt_back(1:len_echo);
end
abDcompressed_signal = abs(Dcompressed_signal);
figure(2);
imagesc(echo_d,x,abDcompressed_signal);    
colormap(gray);
title('距离向压缩后的回波灰度图');
xlabel('距离向坐标/m');
ylabel('方位向坐标/m');

%任取一行数据画出距离压缩后的波形，从而测量距离压缩后的主瓣宽度
figure(3);
row_compressed = abDcompressed_signal(2,:);                         %任意一行距离压缩后的数据
plot(echo_t,row_compressed);                      
axis tight;
title('经过距离向脉冲压缩后的单个回波');
xlabel('快时间/s');
ylabel('幅度');

[maxvalue,index] = max(abDcompressed_signal(2,:));                   %求出最大数值的列

max_column = Dcompressed_signal(:,index);                            %取出峰值所在的列
%先画出实部的波形
figure(4);
subplot(211);
plot(x/v0,real(max_column));
axis tight;
title('峰值所在距离线上的实部波形');
xlabel('慢时间/s');
ylabel('幅度');
%求出并画出慢时间的相位谱
NFFT_max = 2^nextpow2(ND);                                          %求相位谱时的fft点数
n_max = 0 : NFFT_max - 1;
FSt = fft(max_column,NFFT_max);                                     %主瓣（峰值）所在的距离线
subplot(212);
plot(n_max/NFFT_max*PRF,phase(FSt));
axis tight;
title('峰值所在距离线上的相位谱');
xlabel('频率/Hz');
ylabel('相位');

%方位向脉冲压缩
NFFT_R = 2^nextpow2(2*ND-1);                                        %方向位fft的点数 
fdr = -2*v0^2/(Lamda*Rn);                                           %多普勒线性调频斜率
n = 1 : ND;
R_filter = exp(-1i*pi*fdr*(n*PRT).^2);                              %方位向匹配滤波的冲击响应
FR_filter = fft(R_filter,NFFT_R);
RDcompressed_signal = zeros(ND,len_echo);
for nr = 1 : len_echo
    FRt = fft(Dcompressed_signal(:,nr),NFFT_R);
    Rcompressed_signal = ifft(FRt.*FR_filter.');
    RDcompressed_signal(:,nr) = Rcompressed_signal(1:ND);
end
abRDcompressed_signal = abs(RDcompressed_signal);
figure(5);
imagesc(echo_d,x,abRDcompressed_signal);    
colormap(gray);
title('单点目标成像');
xlabel('距离向坐标/m');
ylabel('方位向坐标/m');
axis([15190 15210 -15 15]);

%Q4观察方位向的主瓣和旁瓣
figure(6);
plot(x/v0,abRDcompressed_signal(:,index));         %方位向压缩后的脉冲，是第index列
axis tight;
title('二维压缩后的方位向幅度波形');
xlabel('慢时间/s');
ylabel('幅度');

%目标1和目标2
x2 = (-Ls/2+targetX1):(PRT*v0):(Ls/2+targetX2);
Rnd1 = sqrt((x2-targetX1).^2+Rn^2);
Rnd2 = sqrt((x2-targetX2).^2+Rn^2);
tnd1 = 2*Rnd1/c;                           %目标1的时间延迟向量
tnd2 = 2*Rnd2/c;                           %目标2的时间延迟向量
ND2 = length(x2);
St_back_total = zeros(ND2,len_echo);       %回波信号矩阵
for m = 1 : ND2
    St_back_total(m,:) = rectpuls((x2(m)-targetX1)/Ls)*rectpuls((echo_t-tnd1(m)-Tp/2)/Tp).*exp(1i*pi*Kr*(echo_t-tnd1(m)).^2).*exp(1i*2*pi*fc*(-tnd1(m)))+...             %目标1的回波
                         rectpuls((x2(m)-targetX2)/Ls)*rectpuls((echo_t-tnd2(m)-Tp/2)/Tp).*exp(1i*pi*Kr*(echo_t-tnd2(m)).^2).*exp(1i*2*pi*fc*(-tnd2(m)));                %目标2的回波
end

%距离向脉冲压缩
Dcompressed_signal_total = zeros(ND2,len_echo);
for m = 1 : ND2
    FSt_back_total = fft(St_back_total(m,:),NFFT_D);
    compressed_signal_total = ifft(FSt_back_total.*F_filter);
    Dcompressed_signal_total(m,:) = compressed_signal_total(1:len_echo);
end

%两点目标回波距离压缩后的时域幅度
figure(7);
imagesc(echo_d,x2,abs(Dcompressed_signal_total));       
colormap(gray);
title('两点目标回波距离压缩后的时域幅度');
xlabel('距离向坐标/m');
ylabel('方位向坐标/m');

%方位向脉冲压缩
NFFT_R2 = 2^nextpow2(2*ND2-1);                          %两点目标的方位向fft点数
n2 = 1 : ND2;
R_filter_total = exp(-1i*pi*fdr*(n2*PRT).^2);
FR_filter_total = fft(R_filter_total,NFFT_R2);
RDcompressed_signal_total = zeros(ND2,len_echo);
for nr = 1 : len_echo
    FRt_total = fft(Dcompressed_signal_total(:,nr),NFFT_R2);
    Rcompressed_signal_total = ifft(FRt_total.*FR_filter_total.');
    RDcompressed_signal_total(:,nr) = Rcompressed_signal_total(1:ND2);
end

%两点目标回波二维压缩后的时域幅度
figure(8);
imagesc(echo_d,x2,abs(RDcompressed_signal_total));     
colormap(gray);
title('两点目标二维压缩后的时域幅度');
xlabel('距离向坐标/m');
ylabel('方位向坐标/m');

