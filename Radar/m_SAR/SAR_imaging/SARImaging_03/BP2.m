clc;   close all;clear
%% ---------------------- 雷达参数 ---------------------------------
C                            = 3e8;
Fc                           = 16.2e9;
lambda                       = C/Fc;
Lsar = 2.4;
%% --------------------- 目标距离范围 ------------------------------
Rmin                          = 30;
Rmax                          = 50;
%% ------------------ 慢时间参数(方位向) ----------------------------
Na = 100;
RadarY                        = -Lsar/2+(0:Na-1)*Lsar/Na;                  % 雷达运动轨迹
%% ------------------ 快时间参数(距离向) ----------------------------
Tr                            = 10e-6;                                     % 脉冲宽度 [s]
Br                            = 200e6;                                     % 带宽 [Hz]
Kr                            = Br/Tr;                                     % 调频率 [Hz/s]
Fsr                           = 500e6;                                     % 快时间采样间隔 [s]
dt                            = 1/Fsr;

Nr                           = floor((2*(Rmax - Rmin)/C + Tr)*Fsr) ;
NrEffect                     = floor(2*(Rmax - Rmin)/C *Fsr) ;             %回波点数
tm                           = (0:Nr-1)/Fsr + 2*Rmin/C ;                   %时间轴(Nr)
r                            = tm(1:NrEffect)*C/2 ;                        %距离轴(NrEffect)
%% ---------------------- 分辨率 ---------------------------------
DY                            = 0.886*C/2/Br;                              %距离向分辨率 [m]
DX                            = 0.886*lambda / (2*Lsar);                   %方位角分辨率 [rad]

%% --------------------- 目标参数设置 -----------------------------
Ntarget                                 = 3;                               %目标个数
Ptarget                                 =  [[0  40]; [0 34];[0.6 46]]  ;                       %目标位置
%% --------------------- 生成回波信号 -----------------------------
Sr = zeros(Na,Nr);
for k=1:1:Ntarget
    Rslow                                = RadarY - Ptarget(k,1);                %雷达与目标的方位向距离
    R                                     = sqrt (Rslow.^2 + Ptarget(k,2)^2 );    %雷达与目标点的斜距
    Tdelay                               = 2*R/C;
    Tfast                                = ones(Na,1)*tm -Tdelay'*ones(1,Nr);    %每一行放置对应的距离时延,方便t做减法
    phase                                = pi*Kr*(Tfast-Tr/2).^2 - (4*pi/lambda)*R'*ones(1,Nr);
    Sr                                   = Sr+ exp (1i*phase ).*(0<Tfast&Tfast<Tr);
end
Gr = abs(Sr);
figure;
imagesc(r(1:NrEffect) ,RadarY ,abs(Gr(:,(1:NrEffect))));
title('无脉冲压缩');xlabel('距离向');ylabel('方位向');
%% ---------------------- 脉冲压缩 --------------------------------
tr                                      = tm - 2*Rmin/C;                   %目的就是得到Nr个点,且与发射信号采样率相同
Refr                                    = exp(1i*pi*Kr*(tr-Tr/2).^2).*(0<tr&tr<Tr);
F_Refr                                  = fft((Refr));
Srmy                                    = zeros(Na,Nr);
for k1                                 = 1:1:Na
    temp1                              = fft(Sr(k1,:));
    FSrmy                              = temp1.*conj(F_Refr);
    Srmy(k1,:)                         = ifft(FSrmy);
end

%% ------------------------ 画图 ---------------------------------
figure;
imagesc(r(1:NrEffect) ,RadarY ,abs(Srmy(:,(1:NrEffect))));
title('脉冲压缩后');xlabel('距离向');ylabel('方位向');

%% ----------------------- 画网格 ---------------------------------
detax                                    = 0.01;                           % 方位向网格宽度
detay                                    = 0.02;                           % 距离向网格宽度s
XAxis                                    = -1 : detax :1 ;           % 方位轴
YAxis                                    = 30: detay : 50 ;          % 距离轴
N                                        = length(XAxis);                  % 方位向网格个数
M                                        = length(YAxis);                  % 距离向网格个数
Y                                        = ones(N,1)*(YAxis);
X                                        = XAxis'*ones(1,M);
f_back                                   = zeros(N,M);                     % 反投成像

Nr_up                                    = 10*Nr;                          %升采样后的点数
tempInterp                               = zeros(1,Nr_up+1);
dtr                                      = dt/10;                          %升采样后时间间隔
for ii = 1:Na
    temp                                   = fft (Srmy(ii,:));                                 % 取回波
    tempInterp(1:Nr_up)                    = ifft(fftshift([zeros(1,floor((Nr_up-Nr)/2)),fftshift(temp),zeros(1,Nr_up-Nr-floor((Nr_up-Nr)/2))]));% 升采样
    R_ij                                   = sqrt(Y.^2+(X - RadarY(ii) ).^2);       % 每个网格离雷达的距离
    t_ij                                   = 2 * R_ij /C;
    t_ij                                   = floor((t_ij-(2*Rmin/C))/dtr)+1;        % 以Rmin位置为参考点对应在回波的第几个点
    it_ij                                  = (t_ij>0 & t_ij<=Nr_up);                % 所对应的点不超过范围
    t_ij                                   = t_ij.*it_ij+(Nr_up+1)*(1-it_ij);
    f_back                                 = f_back+ tempInterp(t_ij ).*exp(1i*4*pi*R_ij/lambda); %相位补偿、叠加处理
end
figure('Name','BP算法处理后');
%% -------------------------- 成像 -------------------------------
imagesc(YAxis ,XAxis ,abs(f_back));
title('BP算法处理后');xlabel('距离向');ylabel('方位向');

