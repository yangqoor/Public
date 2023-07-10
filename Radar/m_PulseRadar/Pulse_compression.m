clear all;
close all;
clc;
%%定义参数
N=4096;  %信号的采样个数
fs=1e8   %采样率Hz
t=(0:N-1)/fs;   %仿真时间
f0=10e9;   %载频频率Hz
Tp=10e-6;   %脉冲宽度s
gamma=1e12 %线性调频率  B = gamma * Tp
tao=2e-5


%%构造回波信号 S
S=rectpuls(t-Tp/2-tao,Tp).*exp(j*pi*gamma*(t-Tp/2-tao).^2).*exp(-2j*pi*f0*tao);
figure(1)
plot((t*3e8)/2,real(S),'b','linewidth',2.5);
hold on
%plot((t*3e8)/2,imag(S),'r','linewidth',2.5);
grid on;
legend('回波信号实部,I路','回波信号虚部，Q路')
title('回波信号的实部与虚部')
xlabel('距离，单位m');
ylabel('回波信号幅度');

%%回波频谱分析
fft_Num=4096;
f=fs*(-2048:2047)/fft_Num;
Spetrum1=fftshift(fft(S,fft_Num));
figure(2)
plot(f,abs(Spetrum1),'linewidth',2.5);
grid on;
title('回波信号频谱')
xlabel('频率，单位HZ');
ylabel('回波信号幅度');

%%构造参考信号Sn
Sn=rectpuls(t-Tp/2,Tp).*exp(j*pi*gamma*(t-Tp/2).^2);
figure(3)
plot((t*3e8)/2,real(Sn),'b','linewidth',2.5);
hold on
%plot((t*3e8)/2,imag(Sn),'r','linewidth',2.5)
grid on;
legend('参考信号实部,I路','参考信号虚部，Q路');
title('参考信号的实部与虚部')
xlabel('距离，单位m');
ylabel('参考信号幅度');

%%参考信号频谱分析
fft_Num=4096;
f=fs*(-2048:2047)/fft_Num;
Spetrum2=fftshift(fft(Sn,fft_Num));
figure(4)
plot(f,abs(Spetrum2),'linewidth',2.5);
grid on;
title('参考信号频谱')
xlabel('频率，单位HZ');
ylabel('参考信号幅度');

%%参考信号共轭相乘
gonge=conj(Spetrum2)
result=gonge.*Spetrum1;
fft_Num=4096;
f=fs*(0:fft_Num-1)/fft_Num;
Spetrum3=ifft(result,fft_Num);
figure(5)
plot((t*3e8)/2,abs(Spetrum3),'linewidth',2.5);
grid on;
title('脉压后时域波形');
xlabel('距离，单位m');
ylabel('信号幅度');
figure(6)
Spetrum4=20*log10(abs(Spetrum3));
plot((t*3e8)/2,Spetrum4,'linewidth',2.5);
grid on;
title('脉压后时域波形,单位dB')
xlabel('距离，单位m');
ylabel('信号幅度dB');

figure(7)
Spetrum5=max(abs(Spetrum3));
Spetrum6=Spetrum3/Spetrum5;
Spetrum6=20*log10(abs(Spetrum6));
plot((t*3e8)/2,Spetrum6,'linewidth',2.5);
grid on;
title('归一化后脉压后时域波形,单位dB')
xlabel('距离，单位m');
ylabel('信号幅度dB');