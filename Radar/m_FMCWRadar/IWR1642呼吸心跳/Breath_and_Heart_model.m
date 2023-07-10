%% FMCW毫米波雷达呼吸心跳仿真
clc;
close all;
clear all;
%% 
include_heartbeat = true;
sig_amp_heartbeat = 0.3;

Breath_PerMinute    = 20;   %呼吸次数设置
Heartbeat_PerMinute = 73;   %心跳次数设置
Breath_Var    = 0.05;
Heartbeat_Var = 0.05;  

fs = 50;    %采样率
SNR = 40;   %噪声信噪比
NonLinear = true; %非线性使能

sim_cnt = 50; %播放的时间 呼吸心跳频率有一定的误差变化

%% 仿真
ts = 1/fs;
n = 5000;
T = n/fs;  %仿真时间
t = 0:ts:T;
    
for kk=1:sim_cnt
    
    wb =Breath_PerMinute/60 * 2*pi * (1+2*(rand-0.5)*Breath_Var);         %呼吸频率 计算 加上方差
    wh = Heartbeat_PerMinute/60 * 2*pi * (1+2*(rand-0.5)*Heartbeat_Var);   %心跳频率 计算 加上方差

    fb=wb/(2*pi);
    fh=wh/(2*pi);
    
    pb = 0.05*(rand(n,1)-0.5); %呼吸信号相位噪声
    pb2 = 2*pb;
    ph = 0.05*(rand(n,1)-0.5); %心跳信号相位噪声
    
    for k=2:n
        pb(k)  = pb(k) + pb(k-1) + wb*ts;    %相位计算
        pb2(k) = pb2(k) + pb2(k-1) + 2*wb*ts;%呼吸相位计算
        ph(k)  = ph(k) + ph(k-1) + wh*ts;    %心跳相位计算
    end

    if NonLinear 
        xb = sin(pb) + 0.15 * sin(pb2);    %呼吸信号
    else
        xb = sin(pb);
    end
    
    xh = sig_amp_heartbeat * sin(ph + 2*pi*rand);%心跳信号
    
    if ~include_heartbeat
        x = xb; 
    else
        x = xb + xh; %呼吸和心跳的信号叠加
    end
    
    x = awgn(x, SNR); %呼吸和心跳的信号叠加，再加上高斯白噪声
    %
    if NonLinear
        y = x.^3;     %非线性运算
    else
        y = x;
    end
    
    %% 绘图
    f = abs(fft(y(1:1024)));%呼吸心跳信号谱估计（FFT）
    subplot(211)
    plot(y(1:1024)); 
    xlabel('时间(s)');
    ylabel('幅度(A)');
    title('呼吸心跳时域信号');
    
    subplot(212)
    plot((fs/1024)*((1:128)-1),f(1:128));  %呼吸和心跳频率
    title(['呼吸心跳信号谱估计:','呼吸：',num2str(fb*60),'   心跳：',num2str(fh*60)]);
    pause(1);
end
%%
% save('vital_sign_sim.mat','y');
% figure; plot(y); fs
%% 其他算法开发: