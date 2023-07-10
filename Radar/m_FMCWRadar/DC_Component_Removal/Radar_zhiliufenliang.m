%% 直流分量抑制 平均法（均值相消法）
%% 调皮的连续波 公众号
%% 调皮哥
%% 邮箱：tiaopige@qq.com
clc;
close all;
clear all;
%% 
%% 雷达参数
Tx_Number = 2;               %发射天线
Rx_Number = 4;               %接收天线
Range_Number = 128;          %距离点数（每个脉冲128个点）
Doppler_Number = 128;        %多普勒通道数(总共128个重复脉冲数)
global Params;
Params.NChirp = Doppler_Number;               %1帧数据的chirp个数
Params.NChan =  Rx_Number;                    %RxAn数,ADC通道数
Params.NSample = Range_Number;                %每个chirp ADC采样数
Params.Fs = 2.5e6;                           %采样频率
Params.c = 3.0e8;                     %光速
Params.startFreq = 77e9;              %起始频率 
Params.freqSlope = 60e12;             %chirp的斜率
Params.bandwidth = 3.072e9;           %真实带宽
Params.lambda=Params.c/Params.startFreq;    %雷达信号波长
Params.Tc = 144e-6;                         %chirp周期
global FFT2_mag;

%% 坐标计算
[X,Y] = meshgrid(Params.c*(0:Params.NSample-1)*Params.Fs/2/Params.freqSlope/Params.NSample, ...
    (-Params.NChirp/2:Params.NChirp/2 - 1)*Params.lambda/Params.Tc/Params.NChirp/2);   

%% 距离时域信号直流分量去除
load ReIm_Data_All.mat ;
fft1d_jingtai = zeros(Doppler_Number,Range_Number,Tx_Number*Rx_Number);
for n=1:Tx_Number*Rx_Number
    avg = sum(ReIm_Data_All(:,:,n),2)/Range_Number;
    for chirp=1:Range_Number
        fft1d_jingtai(:,chirp,n) = ReIm_Data_All(:,chirp,n)-avg;
    end
end

%% 1D FFT
fft1d= zeros(Doppler_Number,Range_Number,Tx_Number*Rx_Number);
for qq =1:Tx_Number*Rx_Number
    for chirp_fft=1:Doppler_Number 
        fft1d(chirp_fft,:,qq) = fft((fft1d_jingtai(chirp_fft,:,qq)));
    end
end
FFT1_mag=abs(fft1d(:,:,1));
figure();
mesh(FFT1_mag);
xlabel('采样点数');ylabel('脉冲数');zlabel('幅度');
title('距离维FFT结果');

%% 静态杂波滤除 速度维度的直流分量去除
fft1d_jingtai = zeros(Doppler_Number,Range_Number,Tx_Number*Rx_Number);
for n=1:Tx_Number*Rx_Number
    avg = sum(fft1d(:,:,n))/Doppler_Number;

    for chirp=1:Doppler_Number
        fft1d_jingtai(chirp,:,n) = fft1d(chirp,:,n)-avg;
    end
end
fft1d =fft1d_jingtai;
FFT1_mag=(abs(fft1d(:,:,1)));
figure();
mesh(X,Y,FFT1_mag);
xlabel('距离维(m)');ylabel('速度维(m/s)');zlabel('幅度');
title('相量均值相消后1D-FFT结果');


%% 2D FFT 
fft2d= zeros(Doppler_Number,Range_Number,Tx_Number*Rx_Number);
for kk=1:Tx_Number*Rx_Number
    for chirp_fft=1:Range_Number 
         fft2d(:,chirp_fft,kk) =fftshift( fft((fft1d(:,chirp_fft,kk))));  
    end
end
FFT2_mag=(abs(fft2d(:,:,1)));
figure();
mesh(X,Y,FFT2_mag);
xlabel('距离维(m)');ylabel('速度维(m/s)');zlabel('幅度');
title('相量均值相消后2D-FFT结果');
