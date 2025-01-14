clc;clear;close all

%% 读取数据
%-------------------------------------------------------------------------------------------
%%% adc_data_wall.bin 
% 测量目标是位于2m左右的墙 由AWR1243+DCA1000获取回波数据
% Nadc = 512 Nframe = 1 Nchirp = 128 一帧中128个chirp信号 每个chirp信号采样512个点
% filename = 'adc_data_wall.bin  ';

%%% adc_data_sim.bin  
% 由mmWave Studio中设置的仿真点目标(Range,Velocity) (5,5) (8,-6) 
% Nadc = 512 Nframe = 1 Nchirp = 128 一帧中128个chirp信号 每个chirp信号采样512个点
% filename = 'adc_data_sim.bin ';

%%% adc_data_simAngleFFT
% 由mmWave Studio中设置的仿真点目标 [(x,y,z),Velocity,SignalLevel] 
% 目标1：[(4,4,0),5,-2.5] 目标2：[(0,8,0),-3,-15]
% Nadc = 512 Nframe = 1 Nchirp = 128 使能发射天线Tx0,Tx2 接收天线Rx0,Rx1,Rx2,Rx3
% filename = 'adc_data_simAngleFFT.bin';
%-------------------------------------------------------------------------------------------

% 触发雷达信号并接受回波
% run('CaptrueData.m');
% 等待ADC数据读取
pause(2);
% ADC数据地址
filename = 'adc_data_simAngleFFT.bin';
% 读取数据
adcData = readDCA1000(filename);

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
Nrx = 4;                     % 接收天线Rx数量
Ntx = 2;                     % 发射天线Tx数量
Nant = Nrx*Ntx;

%% 雷达系统参数
Tchirp = Ts*Nadc;                           % ADC采样时间
B = K*Tchirp;                               % 采样信号带宽
rangeRes = c/(2*B);                         % 距离分辨率
fc = f0+B/2;                                % 中间频率
Tc = (RampEndTime+IdleTime)*Ntx;            
% Tc = 总的chirp信号时长，包含空闲时间 
% 在使用TDM-MIMO时要注意，Tc是对于同1个Tx的相邻两个Chirp信号之间的间隔 所以要Tc×Ntx => 速度分辨率减小
% 当然也可以将不同Tx的Chirp信号合并处理，则原有的Tc不变，Nchirp增大Ntx倍（Nchirp×Ntx）=>速度分辨率增大
lambda = c/fc;                      
velRes = lambda/(2*Tc*Nchirp);              % 速度分辨率
d = lambda/2;                               % 等效阵元的间距
angleRes = (lambda/(Nant*d))*180/pi;       % 角度分辨率
% --------------------------------------------------------------------------------
%% 重排回波数据
rawDataTx = zeros(Nrx*Ntx,Nadc,Nchirp); 
% format: [Nrx*Ntx,Nadc,Nchirp]
% [Rx0Tx0 Rx0Tx1 | Rx1Tx0 Rx1Tx1 | Rx2Tx0 Rx2Tx1 | Rx3Tx0 Rx3Tx1]
channal = 0;    %初始化通道数
for ii = 1:Nrx
    tempData = squeeze(adcData(ii,:));               
    tempData = reshape(tempData,Nadc,[]);
    for jj = 1:Ntx
        channal = channal + 1; % 通道数递增1 最大通道数channalMax = Nrx*Ntx
        rawDataTx(channal,:,:)  = tempData(:,jj:Ntx:end);
    end
end
% [Rx0Tx0 Rx1Tx0 Rx2Tx0 Rx3Tx0 | Rx0Tx1 Rx1Tx1 Rx2Tx1 Rx3Tx1]
rawDataRx = zeros(Nrx*Ntx,Nadc,Nchirp);
for jj = 1:Ntx
    rawDataRx(1+Nrx*(jj-1):Nrx*jj,:,:) = rawDataTx(jj:Ntx:end,:,:);
end
% --------------------------------------------------------------------------------
% 虚拟 阵元设置 根据Rx和Tx的位置关系设置
% [Rx3Tx0 Rx2Tx0 Rx1Tx0 Rx0Tx0 | Rx3Tx1 Rx2Tx1 Rx1Tx1 Rx0Tx1]
rawDataVx = zeros(Nrx*Ntx,Nadc,Nchirp);
for jj = 1:Ntx
    rawDataVx(1+Nrx*(jj-1):Nrx*jj,:,:) = rawDataTx(flip(jj:Ntx:end),:,:);
end
%% Take Range-FFT 
nFFT = 1024;
rawData = rawDataVx;
rawData = rawData.*hanning(Nadc).';                % 加窗，抑制频谱泄露
% 1D-FFT
rawDataFFT1 = fft(rawData,nFFT,2); 
% 2D-FFT
rawDataFFT2 = fft(rawDataFFT1,nFFT,3);
rawDataFFT2 = fftshift(rawDataFFT2,3);
% 3D-FFT
% 通过RD图找到目标峰值对应的索引并沿通道维做FFT
angleFFTargetOne = fftshift(fft(rawDataFFT2(:,270,792),nFFT)); % 目标1位置 强度（-2.5dBFS）
angleFFTargetTwo = fftshift(fft(rawDataFFT2(:,380,280),nFFT)); % 目标2位置 强度（ -15dBFS）
% ----绘制距离FFT图---------------------------------------------------------------
rangeAxis = rangeRes*(0:nFFT-1)*(Nadc/nFFT);
chirpAxis = 1:Nchirp;
rangeFFT = squeeze(rawDataFFT1(1,:,:));
figure('name','距离FFT')
mesh(chirpAxis,rangeAxis,mag2db(abs(rangeFFT)/max(abs(rangeFFT),[],'all')))
colorbar;
view(2)
colorbar;
caxis([-120,0])
xlabel('Chirp脉冲数');
xlim([1,Nchirp]);
ylabel('距离(m)');
ylim([0,rangeAxis(end)]);
title('距离FFT');
% ----------------------------------------------------------------------------------------
% 绘制R-D图
dopplerAxis = velRes*((-nFFT/2:nFFT/2-1))*(Nchirp/nFFT);
dopplerFFT = squeeze(rawDataFFT2(1,:,:));
figure('name','R-D图')
mesh(abs(dopplerFFT)/max(abs(dopplerFFT),[],'all'));
mesh(dopplerAxis,rangeAxis,mag2db(abs(dopplerFFT)/max(abs(dopplerFFT),[],'all')));
view(2);
colorbar;
caxis([-120,0])
xlabel('速度(m/s)');
xlim([dopplerAxis(1),dopplerAxis(end)]);
ylabel('距离(m)');
ylim([0,rangeAxis(end)]);
title('R-D图');
%------------------------------------------------------------------------------------------
% 绘制角度FFT图
angleAxis = angleRes*(-nFFT/2:nFFT/2-1)*(Nant/nFFT);
angleAxis = angleAxis./cosd(angleAxis);
figure('name','角度FFT')
plot(angleAxis,abs(angleFFTargetOne/max(angleFFTargetOne)));hold on
plot(angleAxis,abs(angleFFTargetTwo/max(angleFFTargetTwo)));
legend('目标1','目标2');
xlabel('角度(°)');
xlim([-90,90]);
ylabel('幅值');
title('角度FFT');