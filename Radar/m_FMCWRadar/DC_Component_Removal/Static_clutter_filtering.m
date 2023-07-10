
%% 作者：调皮连续波
%% 公众号：调皮的连续波
%% 时间2022年04月
%%
clc;
close all;
clear all;

%% 雷达参数
Tx_Number = 2;               %发射天线
Rx_Number = 4;               %接收天线
Range_Number = 128;          %距离点数（每个chirp 128个点）
Doppler_Number = 128;         %多普勒通道数
global Params;
Params.NChirp = Doppler_Number;               %1帧数据的chirp个数
Params.NChan =  Rx_Number;                    %RxAn数,ADC通道数
Params.NSample = Range_Number;                %每个chirp ADC采样数
Params.Fs = 2.5e6;                          %采样频率
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
       
adc_data =load('angle_15.mat');
Data_dec=(adc_data.prompt_1);  %将16进制转换为10进制

%% 数据读取、拆分、组合
Data_zuhe=zeros(1,Tx_Number*Rx_Number*Doppler_Number*Range_Number*2); %建立计算存储数据的空矩阵
for i=1:1:Tx_Number*Rx_Number*Doppler_Number*Range_Number*2
    
    Data_zuhe(i) = Data_dec((i-1)*2+1)+Data_dec((i-1)*2+2)*256;%两个字节组成一个数，第二个字节乘以256相当于左移8位。
    if(Data_zuhe(i)>32767)
        Data_zuhe(i) = Data_zuhe(i) - 65536;  %限制幅度
    end
end

%% 分放数据
ADC_Data=zeros(Tx_Number,Doppler_Number,Rx_Number,Range_Number*2); %建立计算存储数据的空矩阵
for t=1:1:Tx_Number
    for i=1:1:Doppler_Number
        for j=1:1:Rx_Number
            for k=1:1:Range_Number*2 %实部虚部
                ADC_Data(t,i,j,k) = Data_zuhe(1,(((t-1)*Doppler_Number+(i-1))*Rx_Number+(j-1))*Range_Number*2+k);%时域数据排列顺序为 TX1 TX2
            end
        end
    end
end

%% 打印全部的实虚数据
Re_Data_All=zeros(1,Range_Number*Doppler_Number*Tx_Number*Rx_Number); %建立计算存储数据的空矩阵
Im_Data_All=zeros(1,Range_Number*Doppler_Number*Tx_Number*Rx_Number); %建立计算存储数据的空矩阵

% 虚部实部分解
for i=1:1:Tx_Number*Rx_Number*Doppler_Number*Range_Number
    Im_Data_All(1,i) = Data_zuhe(1,(i-1)*2+1);
    Re_Data_All(1,i) = Data_zuhe(1,(i-1)*2+2);
end

% 原始信号实部、虚部图形绘制 
% figure()
% subplot(2,1,1);
% plot(Im_Data_All(1,1:3000));title('实部波形');
% xlabel('采样点数');
% ylabel('幅度');
% subplot(2,1,2);
% plot(Re_Data_All(1,1:3000),'r');title('虚部波形');
% xlabel('采样点数');
% ylabel('幅度');

%% 打印分组后的实虚数据 数据结构为：2T4R在TX2组的16个脉冲数据
Re_Data=zeros(Doppler_Number,Range_Number); %建立计算存储数据的空矩阵
Im_Data=zeros(Doppler_Number,Range_Number); %建立计算存储数据的空矩阵

for chirp=1:Doppler_Number %查看所在chirp的数据 
for j=1:1:Tx_Number
    for k=1:1:Rx_Number
        for i=1:1:Range_Number
            Re_Data(chirp,i) = ADC_Data(j,chirp,k,(i-1)*2+2);
            Im_Data(chirp,i) = ADC_Data(j,chirp,k,(i-1)*2+1);
        end
    end 
end
end

%% 虚部+实部数据重组得到复信号 
ReIm_Data = complex(Re_Data,Im_Data); %这里只用虚拟天线的最后一组数据。原本数据大小应该是16*256*8=32768，现在只有16*256*1=4096。
ReIm_Data_All =complex(Re_Data_All,Im_Data_All);

ReIm_Data_all1 = zeros(Range_Number,Doppler_Number,4);
ReIm_Data_all2 = zeros(Range_Number,Doppler_Number,4);

%% 虚拟阵列重组 4通道->8通道
for nn=1:4
    for mm=1:Range_Number       
            ReIm_Data_all1(mm,:,nn) = ReIm_Data_All((nn-1)*Range_Number+ ((mm-1)*4*Range_Number+1):((mm-1)*4*Range_Number+Range_Number)+(nn-1)*Range_Number  );          
            ReIm_Data_all2(mm,:,nn) = ReIm_Data_All((nn-1)*Range_Number+131072/2+((mm-1)*4*Range_Number+1):131072/2+((mm-1)*4*Range_Number+Range_Number) +(nn-1)*Range_Number );
    end
end

ReIm_Data_All = cat(3,ReIm_Data_all1(:,:,1:4), ReIm_Data_all2(:,:,1:4));

%% 1D FFT
fft1d= zeros(Doppler_Number,Range_Number,8);
for qq =1:8
    for chirp_fft=1:Doppler_Number 
        fft1d(chirp_fft,:,qq) = fft((ReIm_Data_All(chirp_fft,:,qq)));
    end
end

FFT1_mag=abs(fft1d(:,:,1));
figure(1);
mesh(FFT1_mag);
xlabel('采样点数');ylabel('脉冲数');zlabel('幅度');
title('距离维FFT结果');

%%  MTI 动目标显示
fft1d_MTI= zeros(Range_Number,Doppler_Number,8);
for cc =1:8
    for ii =1:Doppler_Number-1
        fft1d_MTI (ii,:,cc) = fft1d(ii+1,:,cc)-fft1d(ii,:,cc);
    end
end
% 
% 
% mesh(abs(ReIm_Data_All(:,:,1)));

%%  相量均值相消算法-静态杂波滤除
fft1d_avg = zeros(128,128,8);
for n=1:8
    avg = sum(fft1d(:,:,n))/128;

    for chirp=1:128
        fft1d_avg(chirp,:,n) = fft1d(chirp,:,n)-avg;
    end
end

% figure;
% mesh(X,Y,abs(fft1d_jingtai(:,:,1)));
% fft1d =fft1d_jingtai;
%%

%% 2D FFT 

fft2d= zeros(Doppler_Number,Range_Number,8);
for kk=1:8
    for chirp_fft=1:Range_Number 
        fft2d(:,chirp_fft,kk)     =fftshift( fft((fft1d(:,chirp_fft,kk)))); %未经过静态杂波滤除
        fft2d_MTI(:,chirp_fft,kk) =fftshift( fft((fft1d_MTI(:,chirp_fft,kk)))); %MTI
        fft2d_avg(:,chirp_fft,kk) =fftshift( fft((fft1d_avg(:,chirp_fft,kk)))); %相量均值法
    end
end

figure(2);
fft2d_0 =abs(fft2d(:,:,1));
mesh(X,Y,fft2d_0);
xlabel('距离维(m)');ylabel('速度维(m/s)');zlabel('幅度');
title('R-V谱矩阵');

figure(3);
fft2d_0 =abs(fft2d(:,:,1));
fft2d_0(63:65,:)=0;
mesh(X,Y,fft2d_0);
xlabel('距离维(m)');ylabel('速度维(m/s)');zlabel('幅度');
title('零速通道直接置零法');


figure(4);
mesh(X,Y,abs(fft2d_MTI(:,:,1)));
xlabel('距离维(m)');ylabel('速度维(m/s)');zlabel('幅度');
title('MTI');

figure(5);
mesh(X,Y,abs(fft2d_avg(:,:,1)));
xlabel('距离维(m)');ylabel('速度维(m/s)');zlabel('幅度');
title('相量均值相消');

%直流分量去除 相量均值相消算法-静态杂波滤除
figure(6)
fft2d_avg(:,1,1) =0;
mesh(X,Y,abs(fft2d_avg(:,:,1)));
xlabel('距离维(m)');ylabel('速度维(m/s)');zlabel('幅度');
title('相量均值相消');

