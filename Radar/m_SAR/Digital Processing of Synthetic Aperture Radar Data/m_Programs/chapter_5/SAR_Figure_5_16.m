% SAR_Figure_5_16
% 2016.10.13

close all;clear all;clc;

%% 场景设置
% 雷达设置
C = 3e8;                                                                    % 光速
f0 = 5.3e9;                                                                 % 雷达工作频率
lambda = C/f0;                                                              % 工作波长
La = 3.3;
theta = 0;                                                                  % 波束斜视角
theta = theta/180*pi;
% 平台设置                           
V = 150;                                                                    % 雷达有效速度
Rc = 20e3;                                                                  % 景中心斜距
R0 = Rc*cos(theta);                                                         % 最短斜距
% 距离向设置
Tr = 25e-6;                                                                 % 发射脉冲时宽
Kr = 0.25e12;                                                               % 距离调频率
Kr_pos = Kr;                                                                % 距离调频率
Kr_neg = -Kr;                                                               % 距离调频率
Br = Kr*Tr;
alphaR = 1.2;                                                               % 距离向过采样率
Fr = alphaR*Br;                                                             % 距离向采样频率
dtau = 1/Fr;                                                                % 距离向采样时间间隔
Nr = 256;                                                                   % 距离线数
% 方位向设置
Bdop = 0.886*2*V*cos(theta)/La;                                             % 多普勒带宽
alphaA = 1.3;                                                               % 方位向过采样率
Fa = alphaA*Bdop;                                                           % 方位向采样频率
deta = 1/Fa;                                                                % 方位向采样时间间隔
Na = 256;                                                                   % 方位线数
fc = 2*V*sin(theta)/lambda;                                                 % 多普勒中心频率
thetaBW = 0.886*lambda/La;                                                  % 方位向波束宽度

%% 点目标设置
Ntarget = 1;
Ptarget = [R0,0];                                                           % 距离向坐标，方位向坐标

%% 时间轴、频率轴设置
tau = linspace(-Nr/2,Nr/2-1,Nr)*dtau+2*Rc/C;                                % 距离向时间轴
eta = linspace(-Na/2,Na/2-1,Na)*deta;                                       % 方位向时间轴
tau_m = ones(Na,1)*tau;                                                     % 距离向时间轴矩阵
eta_m = eta'*ones(1,Nr);                                                    % 方位向时间轴矩阵

%% 生成回波信号矩阵
S0_pos = zeros(Na,Nr);
S0_neg = zeros(Na,Nr);
for k = 1:Ntarget
    R = sqrt(Ptarget(k,1)^2+(V*eta_m-Ptarget(k,1)*tan(theta)-Ptarget(k,2)).^2);         % 点目标斜距矩阵
    Wr = abs(tau_m-2*R/C)<Tr/2;                                                         % 矩形窗矩阵
    Wa = sinc(0.886*atan((V*eta_m-Ptarget(k,2))/Ptarget(k,1))/thetaBW).^2;              % 双程波束方向图 P91(4.27) (4.28)
    S0_pos = S0_pos+Wr.*Wa.*exp(-1i*4*pi*f0*R/C).*exp(1i*pi*Kr_pos*(tau_m-2*R/C).^2);   % 生成回波信号矩阵 P156 (6.1)
    S0_neg = S0_neg+Wr.*Wa.*exp(-1i*4*pi*f0*R/C).*exp(1i*pi*Kr_neg*(tau_m-2*R/C).^2);   % 生成回波信号矩阵 P156 (6.1)
end

figure,set(gcf,'Color','w');colormap jet;
subplot(1,3,1),imagesc(abs(S0_pos));axis image
title('（a）幅度');xlabel('距离向（采样点）');ylabel('方位向（采样点）');
subplot(1,3,2),imagesc(angle(S0_pos));axis image
title('（b）相位，正扫描');xlabel('距离向（采样点）');
subplot(1,3,3),imagesc(angle(S0_neg));axis image
title('（c）相位，负扫描');xlabel('距离向（采样点）');
