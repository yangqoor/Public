clc;clear;close all

%% 读取数据
%%% adc_data_wall.bin 
% 测量目标是位于2m左右的墙 由AWR1243+DCA1000获取回波数据
% Nadc = 512 Nframe = 1 Nchirp = 128 一帧中128个chirp信号 每个chirp信号采样512个点
% filename = 'adc_data_wall.bin';

%%% adc_data_sim.bin  
% 由mmWave Studio中设置的仿真点目标(Range,Velocity) (5,5) (8,-6) 
% Nadc = 512 Nframe = 1 Nchirp = 128 一帧中128个chirp信号 每个chirp信号采样512个点
% filename = 'adc_data_sim.bin ';

% 触发雷达信号并接受回波 
% run('CaptrueData.m');
% 等待ADC数据读取
pause(2);
% ADC数据地址
filename = 'adc_data_wall.bin';
% 读取数据
rawData = readDCA1000(filename);

%% 雷达参数设置
c = physconst('lightspeed');
f0 = 77E9;
ADCStartTime = 6E-6;
IdleTime = 10E-6;
RampEndTime = 63.14E-6;
K = 63.343E12;               % 调频率 (Hz/sec)
fStart = f0+K*ADCStartTime;  % 起始频率
fS = 9121e3;                 % ADC采样频率 (sps)
Ts = 1/fS;                   % ADC采样间隔
Nchirp = 128;                % 一个帧的chirp数
Nadc = 512;                  % 一个chirp的adc采样点数
%% 雷达系统参数
Tchirp = Ts*Nadc;                           % ADC采样时间
B = K*Tchirp;                               % 采样信号带宽
rangeRes = c/(2*B);                         % 距离分辨率
fc = f0+B/2;                                % 中间频率
Tc = RampEndTime+IdleTime;                  % 总的chirp信号时长，包含空闲时间
lambda = c/fc;                      
velRes = lambda/(2*Tc*Nchirp);              % 速度分辨率

%% Take Range-FFT 
nFFT = 1024;
rawData = squeeze(rawData(1,:,:));                % 取Rx0的数据
rawData = reshape(rawData,Nadc,Nchirp);
% rawData = rawData.*hanning(Nadc);                % 加窗，抑制频谱泄露
% 1D-FFT
rawDataFFT1 = fft(rawData,nFFT); 
% 2D-FFT
rawDataFFT2 = fft(rawDataFFT1,nFFT,2);
rawDataFFT2 = fftshift(rawDataFFT2,2);
% 绘制距离FFT图
rangeAxis = rangeRes*(0:nFFT-1)*(Nadc/nFFT);
chirpAxis = 1:Nchirp;
figure('name','距离FFT')
mesh(chirpAxis,rangeAxis,mag2db(abs(rawDataFFT1)/max(abs(rawDataFFT1),[],'all')))
colorbar;
view(2)
colorbar;
caxis([-120,0])
xlabel('Chirp脉冲数');
xlim([1,Nchirp]);
ylabel('距离(m)');
ylim([0,rangeAxis(end)]);
title('距离FFT');
% 绘制R-D图
dopplerAxis = velRes*((-nFFT/2:nFFT/2-1))*(Nchirp/nFFT);
figure('name','R-D图')
mesh(dopplerAxis,rangeAxis,mag2db(abs(rawDataFFT2)/max(abs(rawDataFFT2),[],'all')));
view(2);
colorbar;
caxis([-120,0])
xlabel('速度(m/s)');
xlim([dopplerAxis(1),dopplerAxis(end)]);
ylabel('距离(m)');
ylim([0,rangeAxis(end)]);
title('R-D图');