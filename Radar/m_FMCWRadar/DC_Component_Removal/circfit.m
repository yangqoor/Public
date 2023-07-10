%% 圆拟合算法 直流分量抑制 
%% 公众号:调皮的连续波 
%% 调皮哥
%% 邮箱：tiaopige@qq.com
clc;
close all;
clear all;

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
load ReIm_Data_All_circ.mat ;
fft1d_before=ReIm_Data_All;

AmR=zeros(Range_Number,Doppler_Number);
dataR=zeros(Range_Number,Doppler_Number,Tx_Number*Rx_Number);

 for antenna=1:Tx_Number*Rx_Number
    for Range=1:Range_Number
        %1.估计每个扫频周期时间内的基带复信号中频信号的幅值
        AmR(Range,:)=fft1d_before(Range,:,antenna);
        
        %2.幅值时间序列和已知的初始相位时间序列得到复平面上的离散点       
%         figure(2);
%         plot(fft1d(:,doppler,1),'o');
%         title([num2str(doppler)]);
        
        %3.一个距离门上的所有多普勒点进行圆拟合
        xdataR=real(AmR(Range,:));
        ydataR=imag(AmR(Range,:));
        
        %最小二乘法拟合
        k0 = ones(1,3);
        F = @(k)(xdataR-k(1)).^2+(ydataR-k(2)).^2-k(3)^2;
        [k,resnorm] = lsqnonlin(F,k0);

        %k(1)是圆心的x坐标
        %k(2)是圆心的y坐标
        %k(3)的绝对值是圆的半径
        
%         r0 = [k(1),k(2)];
%         R = abs(k(3));
%         xx = k(1)-R:0.01*R:k(1)+R;
%         y1_h = sqrt(R.^2 - (xx - r0(1)).^2) + r0(2);
%         y2_h = -sqrt(R.^2 - (xx - r0(1)).^2) + r0(2);
%         figure(1);
%         plot(xx,y1_h,'b')
%         hold on
%         plot(xx,y2_h','b')
%         plot(xdata,ydata,'*r')
%         title('距离维圆拟合');
%         xlabel('实部');
%         ylabel('虚部');
%         axis equal %axis square
        
        %4.修正补偿
        %获取拟合圆的圆心
        x=k(1);
        y=k(2);
        
        %将圆心移到零点（0，0）
        xdataR=xdataR-x;
        ydataR=ydataR-y;

        %5.得到新的点的时间序列相位
        dataR(Range,:,antenna)=complex(xdataR,ydataR);
%         hold off;
    end
 end
 
%% 速度维 圆拟合
AmV=zeros(Range_Number,Doppler_Number);
dataV=zeros(Range_Number,Doppler_Number,Tx_Number*Rx_Number);
 for antenna=1:Tx_Number*Rx_Number
    for doppler=1:Doppler_Number
        %1.估计每个扫频周期时间内的基带复信号中频信号的幅值
        AmV(:,doppler)=dataR(:,doppler,antenna);
        
        %2.幅值时间序列和已知的初始相位时间序列得到复平面上的离散点       
%         figure(2);
%         plot(fft1d(:,doppler,1),'o');
%         title([num2str(doppler)]);
        
        %3.一个距离门上的所有多普勒点进行圆拟合
        xdataV=real(AmV(:,doppler));
        ydataV=imag(AmV(:,doppler));
        
        %最小二乘法拟合
        k0 = ones(1,3);
        F = @(k)(xdataV-k(1)).^2+(ydataV-k(2)).^2-k(3)^2;
        [k,resnorm] = lsqnonlin(F,k0);

        %k(1)是圆心的x坐标
        %k(2)是圆心的y坐标
        %k(3)的绝对值是圆的半径
        
%         r0 = [k(1),k(2)];
%         R = abs(k(3));
%         xx = k(1)-R:0.01*R:k(1)+R;
%         y1_h = sqrt(R.^2 - (xx - r0(1)).^2) + r0(2);
%         y2_h = -sqrt(R.^2 - (xx - r0(1)).^2) + r0(2);
%         figure(1);
%         plot(xx,y1_h,'b')
%         hold on
%         plot(xx,y2_h','b')
%         plot(xdata,ydata,'*r')
%         axis equal %axis square
        
        %4.修正补偿
        %获取拟合圆的圆心
        x=k(1);
        y=k(2);
        
        %将圆心移到零点（0，0）
        xdataV=xdataV-x;
        ydataV=ydataV-y;

        %5.得到新的点的时间序列相位
        dataV(:,doppler,antenna)=complex(xdataV,ydataV);
%         hold off;
    end
 end

%% 1D FFT
fft1d= zeros(Range_Number,Doppler_Number,Tx_Number*Rx_Number);
for antenna =1:Tx_Number*Rx_Number
    for Range=1:Range_Number 
        fft1d(Range,:,antenna) = fft((dataV(Range,:,antenna)));
    end
end

FFT1_mag=abs(fft1d(:,:,1));
figure();
mesh(FFT1_mag);
xlabel('采样点数');ylabel('脉冲数');zlabel('幅度');
title('圆拟合 1D-FFT结果');

%% 2D-FFT 
fft2d= zeros(Range_Number,Doppler_Number,Tx_Number*Rx_Number);
for antenna=1:Tx_Number*Rx_Number
    for doppler=1:Doppler_Number 
         fft2d(:,doppler,antenna) =fftshift( fft((fft1d(:,doppler,antenna))));  
    end
end
FFT2_mag=(abs(fft2d(:,:,1)));
figure();
mesh(X,Y,FFT2_mag);
xlabel('距离维(m)');ylabel('速度维(m/s)');zlabel('幅度');
title('圆拟合 2D-FFT结果');
%% END
