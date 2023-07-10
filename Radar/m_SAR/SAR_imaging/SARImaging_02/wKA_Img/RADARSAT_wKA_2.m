% RADARSAT-1�����ݴ���֮wKA����2
% wKA�Ľ���ʵ��

clc;clear all;close all;

%% ��ȡԭʼ����
run specify_parameters.m
run extract_data.m
clear all;

%% ��������
% �״����
C = 2.9979e8;                                                               % ����
f0 = 5.3e9;                                                                 % ����Ƶ��
lambda = C/f0;                                                              % ����
% ����ƽ̨
V = 7062;                                                                   % ƽ̨�ٶ�
% ������
Kr = -0.72135e12;                                                           % ��Ƶ��
Tr = 41.75e-6;                                                              % �������ʱ��
Fr = 32.317e6;                                                              % �����������
dtau = 1/Fr;                                                                % ���������ʱ����
% ��λ��
Ka = 1733;                                                                  % ��λ���Ƶ��
Fa = 1256.98;                                                               % ��λ�������
fc = -6900;                                                                 % ����������Ƶ��
deta = 1/Fa;                                                                % ���������ʱ����
% ��������
t0 = 6.5956e-3;                                                             % ��ȡ����ʱ��
R0 = t0*C/2;                                                                % ���б��

%% ��ȡԭʼ����
oldFolder = cd('.\scene01');
load CDdata1.mat
cd(oldFolder);
data=double(data);
[Na,Nr] = size(data);

%% ȷ���ο�����
Rref = (t0+Nr/2*dtau)*C/2;                                                  % �ο�����ѡ�ڳ�����������

%% ����ĩβ����
Za = 800;                                                                   % ��λ������
Zr = ceil(Tr/dtau);                                                         % ����������
data = cat(2,data,zeros(Na,Zr));                                            % ��������
data = cat(1,zeros(Za,Nr+Zr),data);                                         % ��λ����
Na = Na+Za;
Nr = Nr+Zr;

figure,imagesc(abs(data));axis image;set(gcf,'Color','w');
title('ʱ�򣺲�����ԭʼ�źŷ���');
xlabel('�����򣨲����㣩');ylabel('��λ�򣨲����㣩');

%% ʱ���ᡢƵ��������
tau = t0+(0:Nr-1)*dtau;                                                     % ������ʱ����
ftau = ((0:Nr-1)-Nr/2)/Nr*Fr;                                               % ������Ƶ����
eta = ((0:Na-1)-Na/2)*deta;                                                 % ��λ��ʱ����
feta = fc+((0:Na-1)-Na/2)/Na*Fa;                                            % ��λ��Ƶ����

%% ���뵽��λ�����������
S0 = data.*exp(-1i*2*pi*fc*(eta'*ones(1,Nr)));                              % ������������Ƶ������
clear data

%% �ο��������
Sff = fftshift(fft2(fftshift(S0)));                                         % ��άFFT
clear S0
WindowR = ones(Na,1)*kaiser(Nr,2.5)';                                       % ���봰
WindowA = kaiser(Na,2.5)*ones(1,Nr);                                        % ��λ��
Sff = Sff.*WindowR.*WindowA;                                                % �Ӵ�
clear WindowR WindowA
Hrfm = exp(1i*pi*(4*Rref/C*sqrt((f0+ones(Na,1)*ftau).^2-(C*(feta'*ones(1,Nr))/V/2).^2)+(ones(Na,1)*ftau).^2/Kr)); % ����ο�������ʽ8.3
S1 = Sff.*Hrfm;                                                             % �ο�������ˣ�һ��ѹ������ʽ8.1
clear Sff Hrfm

figure,imagesc(abs(S1));axis image;set(gcf,'Color','w');
title('��άƵ�򣺲ο�������˺���źŷ���');
xlabel('�����򣨲����㣩');ylabel('��λ�򣨲����㣩');

%% ���෽λƥ���˲������
Srd = ifftshift(ifft(ifftshift(S1,2),[],2),2);                              % ������IFFT
clear S1
D = sqrt(1-C^2*feta.^2/(4*V^2*f0^2));                                       % �����㶯����D(feta,V)��ʽ7.17
Happ = exp(1i*4*pi*((ones(Na,1)*tau)*C/2-Rref)*f0.*(D'*ones(1,Nr))/C);      % ���෽λƥ���˲�����ʽ8.35ָ����������R0?
clear D
S2 = Srd.*Happ;                                                             % �˲����
clear Srd Happ

figure,imagesc(abs(S2));axis image;set(gcf,'Color','w');
title('RD�򣺲��෽λƥ���˲�����˺���źŷ���');
xlabel('�����򣨲����㣩');ylabel('��λ�򣨲����㣩');

%% �任��ͼ����
Stt = ifftshift(ifft(ifftshift(S2,1),[],1),1);                              % ��λ��IFFT
clear S2

%% ����ͼ��
Img = flipud(abs(Stt));                                                     % ���·�תͼ��
Ntau = round((Tr/dtau/2-1)/2);                                              % �������������������
Img = Img(1:Na-Za,Ntau+1:Ntau+Nr-Zr);                                       % �ü�ͼ����Ч����
Img = Img/max(max(Img));
Img = 20*log10(Img+eps);
Img(Img<-50) = -50;
Img = uint8((Img+50)/50*255);

figure,imagesc(Img);axis image;set(gcf,'Color','w');
figure,imshow(Img);
imwrite(Img,'SAR_wKA_2.bmp','bmp');
