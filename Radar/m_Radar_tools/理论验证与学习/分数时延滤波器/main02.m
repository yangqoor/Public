%--------------------------------------------------------------------------
%   分数时延滤波器
%--------------------------------------------------------------------------
clear;clc;

tm = 1e-6;
bw = 80e6;
fs = 100e6;
T = 1/fs;
waveform = phased.FMCWWaveform('SweepTime',tm, ...
                               'SweepBandwidth',bw,...
                               'SampleRate',fs,...
                               'SweepInterval','Symmetric');

sig = waveform();
sig = [zeros(100,1);sig;zeros(100,1)];
figure(1);plot(real(sig));grid on;title('原始波形')
D = 0.15;                                                                    %时间延迟点数

%--------------------------------------------------------------------------
%   最大平坦准则逼近法
%--------------------------------------------------------------------------
N = 50;
h = hlagr2(N,D);

sig_f = conv(sig,h);
figure(2);plot(h);grid on;title('最大平坦准则逼近')
figure(3);plot(real(sig_f));grid on;title('滤波后')
figure(4);freqz(h)