%% 正侧视FS算法
% 2020-8-4 by hzh

%%
clc;clear all;close all;

%% 雷达信号参数设置
SignalParaFlag=1;%flag为1时读取雷达信号参数
SignalPara=SetSignalPara(SignalParaFlag);

%% 成像参数
ImageParaFlag=1;
[RangePara,AzimuthPara,RadarPara,TargetPara]=SetImagePara(SignalPara,ImageParaFlag);

%% 回波仿真
[echo,MethodFlag]=SetEcho(SignalPara,RangePara,AzimuthPara,RadarPara,TargetPara);
figure,imagesc(abs(echo));title('回波数据');xlabel('距离向采样点');ylabel('方位向采样点');

%% FSA 参数准备
Na=AzimuthPara.Na;
Nr=RangePara.Nr;

fyita=(-Na/2:Na/2-1)/Na*AzimuthPara.PRF;%多普勒频率
% linspace(-AzimuthPara.PRF/2,AzimuthPara.PRF/2,Na);
kx=2*pi*fyita/RadarPara.Vr;%方位波数

kc = 4*pi*SignalPara.fc/SignalPara.c;
b  = 8*pi*SignalPara.gama/SignalPara.c^2;
Ax = sqrt(1 - (kx/kc).^2);
krDelta = 4*pi*SignalPara.gama*(RangePara.tr-2*RangePara.Rref/SignalPara.c)/SignalPara.c;

Ys=[-Nr/2:Nr/2-1]/Nr*RangePara.fr*(-SignalPara.c/2/SignalPara.gama);
% Ys=[-Nr/2:Nr/2-1]/Nr*(RangePara.tr(Nr)-RangePara.tr(1))*(SignalPara.c/2);
Rc=RangePara.Rc;
Rb=Ys+Rc;%RB为天线到目标的最近距离,Rs 为天线与场景中心的最近距离。

image=myFSA(echo,Rc,SignalPara.fc,SignalPara.gama,RadarPara.Vr/AzimuthPara.PRF,RangePara.fr);

