%  使用czt的方法计算得到的波束形成
clc
clear
close all

% 宽带波束形成

% 创建信号（LFM）
f       = 60;                                     % 信号的中心频率
T       = 5;                                      % 信号的持续时间
B       = 20;                                     % 信号的扩展带宽
K       = B / T;                                  % 调频斜率（chirp slope）
Fs      = 10 * (f + B / 2);                       % 采样频率
Ts      = 1 / Fs;                                 % sampling frequency and sample spacing
N       = T / Ts;                                 % 采样点数
c       = 1500;                                   % 声信号的传播速度

t       = linspace(-T / 2, T / 2, N);             % 信号的持续时间
St      = exp(1i * 2 * pi * (f * t + K * t.^2));  % 原始信号

% 对线性调频信号做fft
num_fft = 2^nextpow2(N);                          % 做傅里叶变化的点数选择离信号点数的
fft_St  = fft(St, num_fft, 2);
M       = 32;                                     % 阵元32
theta   = 30;                                     % 信号方向
f_max   = (f + B / 2);
lambda  = c / f_max;                              % 波长选择最大频率计算
d       = lambda / 2;                             % 阵元间距

% 实际频率分布
f_distribute = (1:1:num_fft) * Fs / num_fft;
% 信号时延
tao          = d * (0:1:M - 1) * sind(theta) / c;
% 信号流行矩阵
Af           = exp(-1i * 2 * pi * f_distribute.' * tao);
% 产生均值为0，方差为1，服从高斯正太分布的白噪声，然后做fft
noise        = 0 * randn(M, N);
fft_noise    = fft(noise, num_fft, 2);

% 接收信号做完fft之后的结果
Signal_add_noise_f = diag(fft_St) * Af + fft_noise.';
% 一般不对角度进行搜索而是对sin（theta）
sin_theta = -1:1 / (4 * M):1;

Power_signal_f = zeros(num_fft, length(sin_theta));

% % 
%  tic;
%  % 对每一个频率做常规波束形成
%  for count=1:1:num_fft
%      % 搜索导向矢量
%      Steer_matrix=exp(-1i*2*pi*f_distribute(count)*...
%          );
%  end

% % 
% 使用czt的方法计算得到的波束形成
Power_signal_czt = zeros(num_fft, length(sin_theta));
delta_s = 1 / (4 * M);
% 一共有num_fft多点的频率
tic;

for cnt = 1:1:num_fft
    % 计算频率
    fk = f_distribute(cnt);
    % 计算起始点
    A  = exp(-1i * 2 * pi * fk * sin_theta(1) * d / c);
    % 计算步长
    W  = exp(1i * 2 * pi * fk * d * delta_s / c);
    % 计算波束形成
    Power_signal_czt(cnt, :) = ...
    czt(Signal_add_noise_f(cnt, :), 8 * M + 1, W, A);
end

toc;

Log_Power2 = 10 * log10(abs(Power_signal_czt) ./ max(max(abs(Power_signal_czt))));
figure(3)
[X, Y] = meshgrid(asind(sin_theta), f_distribute);
mesh(X, Y, Log_Power2);

title('Frequency domian beamforming with CZT')
xlabel('angle/°')
ylabel('frequency/Hz')
zlabel('Beam Power Pattern/dB')
