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
% figure(1);rt.p3(sig);grid on;title('原始波形')

D = 0.05;                                                                    %时间延迟点数
time_axis = -20:20;                                                         %滤波器点数为N+1奇数个最好

%--------------------------------------------------------------------------
%   方法1 加窗法
%--------------------------------------------------------------------------
win = @hann;
h = sinc(time_axis-D).*win(numel(time_axis)).';
sig_f = conv(sig,h);

% figure(2);plot(h);grid on;title('分数延迟滤波器')
% figure(3);rt.p3(sig_f);grid on;title('滤波后')
% figure(4);freqz(h)

%--------------------------------------------------------------------------
%   循环验证
%--------------------------------------------------------------------------

for D = 0:0.01:2                                                            %时间延迟点数
    time_axis = -20:20;                                                         %滤波器点数为N+1奇数个最好
    win = @hann;
    h = sinc(time_axis-D).*win(numel(time_axis)).';
    sig_f = conv(sig,h);
    figure(3);
    subplot(131);rt.p3(sig_f);grid on;title('滤波后')
    axis([0 400 -1 1 -1 1]); view([-10 20])
    subplot(132);plot(real(sig_f));grid on;axis([0 350 -1 1]);
    title(num2str(D))
    subplot(133);plot(imag(sig_f));grid on;axis([0 350 -1 1]);
    drawnow
end
