%% ������FS�㷨
% 2020-8-4 by hzh

%%
clc;clear all;close all;

%% �״��źŲ�������
SignalParaFlag=1;%flagΪ1ʱ��ȡ�״��źŲ���
SignalPara=SetSignalPara(SignalParaFlag);

%% �������
ImageParaFlag=1;
[RangePara,AzimuthPara,RadarPara,TargetPara]=SetImagePara(SignalPara,ImageParaFlag);

%% �ز�����
[echo,MethodFlag]=SetEcho(SignalPara,RangePara,AzimuthPara,RadarPara,TargetPara);
figure,imagesc(abs(echo));title('�ز�����');xlabel('�����������');ylabel('��λ�������');

%% FSA ����׼��
Na=AzimuthPara.Na;
Nr=RangePara.Nr;

fyita=(-Na/2:Na/2-1)/Na*AzimuthPara.PRF;%������Ƶ��
% linspace(-AzimuthPara.PRF/2,AzimuthPara.PRF/2,Na);
kx=2*pi*fyita/RadarPara.Vr;%��λ����

kc = 4*pi*SignalPara.fc/SignalPara.c;
b  = 8*pi*SignalPara.gama/SignalPara.c^2;
Ax = sqrt(1 - (kx/kc).^2);
krDelta = 4*pi*SignalPara.gama*(RangePara.tr-2*RangePara.Rref/SignalPara.c)/SignalPara.c;

Ys=[-Nr/2:Nr/2-1]/Nr*RangePara.fr*(-SignalPara.c/2/SignalPara.gama);
% Ys=[-Nr/2:Nr/2-1]/Nr*(RangePara.tr(Nr)-RangePara.tr(1))*(SignalPara.c/2);
Rc=RangePara.Rc;
Rb=Ys+Rc;%RBΪ���ߵ�Ŀ����������,Rs Ϊ�����볡�����ĵ�������롣

image=myFSA(echo,Rc,SignalPara.fc,SignalPara.gama,RadarPara.Vr/AzimuthPara.PRF,RangePara.fr);

