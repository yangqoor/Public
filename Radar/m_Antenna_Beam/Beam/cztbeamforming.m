%  ʹ��czt�ķ�������õ��Ĳ����γ�
clc
clear
close all

% ��������γ�

% �����źţ�LFM��
f       = 60;                                     % �źŵ�����Ƶ��
T       = 5;                                      % �źŵĳ���ʱ��
B       = 20;                                     % �źŵ���չ����
K       = B / T;                                  % ��Ƶб�ʣ�chirp slope��
Fs      = 10 * (f + B / 2);                       % ����Ƶ��
Ts      = 1 / Fs;                                 % sampling frequency and sample spacing
N       = T / Ts;                                 % ��������
c       = 1500;                                   % ���źŵĴ����ٶ�

t       = linspace(-T / 2, T / 2, N);             % �źŵĳ���ʱ��
St      = exp(1i * 2 * pi * (f * t + K * t.^2));  % ԭʼ�ź�

% �����Ե�Ƶ�ź���fft
num_fft = 2^nextpow2(N);                          % ������Ҷ�仯�ĵ���ѡ�����źŵ�����
fft_St  = fft(St, num_fft, 2);
M       = 32;                                     % ��Ԫ32
theta   = 30;                                     % �źŷ���
f_max   = (f + B / 2);
lambda  = c / f_max;                              % ����ѡ�����Ƶ�ʼ���
d       = lambda / 2;                             % ��Ԫ���

% ʵ��Ƶ�ʷֲ�
f_distribute = (1:1:num_fft) * Fs / num_fft;
% �ź�ʱ��
tao          = d * (0:1:M - 1) * sind(theta) / c;
% �ź����о���
Af           = exp(-1i * 2 * pi * f_distribute.' * tao);
% ������ֵΪ0������Ϊ1�����Ӹ�˹��̫�ֲ��İ�������Ȼ����fft
noise        = 0 * randn(M, N);
fft_noise    = fft(noise, num_fft, 2);

% �����ź�����fft֮��Ľ��
Signal_add_noise_f = diag(fft_St) * Af + fft_noise.';
% һ�㲻�ԽǶȽ����������Ƕ�sin��theta��
sin_theta = -1:1 / (4 * M):1;

Power_signal_f = zeros(num_fft, length(sin_theta));

% % 
%  tic;
%  % ��ÿһ��Ƶ�������沨���γ�
%  for count=1:1:num_fft
%      % ��������ʸ��
%      Steer_matrix=exp(-1i*2*pi*f_distribute(count)*...
%          );
%  end

% % 
% ʹ��czt�ķ�������õ��Ĳ����γ�
Power_signal_czt = zeros(num_fft, length(sin_theta));
delta_s = 1 / (4 * M);
% һ����num_fft����Ƶ��
tic;

for cnt = 1:1:num_fft
    % ����Ƶ��
    fk = f_distribute(cnt);
    % ������ʼ��
    A  = exp(-1i * 2 * pi * fk * sin_theta(1) * d / c);
    % ���㲽��
    W  = exp(1i * 2 * pi * fk * d * delta_s / c);
    % ���㲨���γ�
    Power_signal_czt(cnt, :) = ...
    czt(Signal_add_noise_f(cnt, :), 8 * M + 1, W, A);
end

toc;

Log_Power2 = 10 * log10(abs(Power_signal_czt) ./ max(max(abs(Power_signal_czt))));
figure(3)
[X, Y] = meshgrid(asind(sin_theta), f_distribute);
mesh(X, Y, Log_Power2);

title('Frequency domian beamforming with CZT')
xlabel('angle/��')
ylabel('frequency/Hz')
zlabel('Beam Power Pattern/dB')
