% RADARSAT-1�����ݴ���֮CSA����

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

%% �ο���������
Rref = (t0+Nr/2*dtau)*C/2;                                                  % �ο�����
Vref = V;                                                                   % �ο��ٶ�
fref = fc;                                                                  % �ο�Ƶ��

%% ����ĩβ����
Za = 800;                                                                   % ��λ������Tsar*Fa
Zr = ceil(Tr/dtau);                                                         % ����������Tr*Fr
data = cat(2,data,zeros(Na,Zr));                                            % ��������
data = cat(1,zeros(Za,Nr+Zr),data);                                         % ��λ����
Na = Na+Za;%2336
Nr = Nr+Zr;%3398

figure,imagesc(abs(data));axis image;set(gcf,'Color','w');
title('ʱ�򣺲�����ԭʼ�źŷ���');
xlabel('�����򣨲����㣩');ylabel('��λ�򣨲����㣩');

%% ʱ���ᡢƵ��������
tau = t0+(0:Nr-1)*dtau;                                                     % ������ʱ����
ftau = ((0:Nr-1)-Nr/2)/Nr*Fr;                                               % ������Ƶ����
eta = ((0:Na-1)-Na/2)*deta;                                                 % ��λ��ʱ����
feta = fc+((0:Na-1)-Na/2)/Na*Fa;                                            % ��λ��Ƶ����
%% �м��������
D_feta_V = sqrt(1-C^2*feta.^2/(4*V^2*f0^2));                                % D(feta,V)��ʽ7.17
D_feta_Vref = sqrt(1-C^2*feta.^2/(4*Vref^2*f0^2));                          % D(feta,Vref)��ʽ7.17
D_fref_V = sqrt(1-C^2*fref^2/(4*V^2*f0^2));                                 % D(fref,V)��ʽ7.17
D_fref_Vref = sqrt(1-C^2*fref^2/(4*Vref^2*f0^2));                           % D(fref,Vref)��ʽ7.17

Ksrc = (2*V^2*f0^3*D_feta_V.^3)./(C*R0*feta.^2);                            % SRC�˲����ĵ�Ƶ�ʣ�ʽ6.22        
Km = Kr./(1-Kr./Ksrc);                                                      % �ı��ľ������Ƶ�ʣ�ʽ6.21
%clear Ksrc
RCMbulk = (1./D_feta_Vref-1/D_fref_Vref)*Rref;                              % һ��RCM����ʽ7.22
alpha = D_fref_Vref./D_feta_Vref-1;                                         % Ƶƫ������ʽ7.28

%% ���뵽��λ�����������
S0 = data.*exp(-1i*2*pi*fc*(eta'*ones(1,Nr)));                              % ������������Ƶ������
%clear data

%% �任�������������ʵ�ֱ�����
Srd = fftshift(fft(fftshift(S0,1),[],1),1);                                 % ԭ�ź�����λ��FFT
%clear S0
tt = 2/C*(R0/D_fref_V+RCMbulk)-2*Rref./(C*D_feta_Vref);                     % P205 (7.26) (7.27)
Ssc = exp(1i*pi*Km.*alpha.*tt.^2);                                          % ��귽�� P207 (7.30)
%clear tt
S1 = Srd.*(Ssc'*ones(1,Nr));                                                % �����ˣ���ʽ7.31
%clear Srd Ssc

%% �任����άƵ��ʵ��RC��SRC��һ��RCMC
S2 = fftshift(fft(fftshift(S1,2),[],2),2);                                  % �źű任����άƵ��
%clear S1
WindowR = ones(Na,1)*kaiser(Nr,2.5)';                                       % ���봰
WindowA = kaiser(Na,2.5)*ones(1,Nr);                                        % ��λ��
S2 = S2.*WindowR.*WindowA;                                                  % �Ӵ���ʽ7.32
%clear WindowR WindowA
Hm = exp(1i*pi./((Km'*ones(1,Nr)).*(1+alpha'*ones(1,Nr))).*(ones(Na,1)*ftau).^2); % �ϲ��ľ���ѹ����һ��RCMC�˲�������ʽ7.32,1+alpha
%clear alpha
Hrcm = exp(1i*4*pi/C*(RCMbulk'*ones(1,Nr)).*(ones(Na,1)*ftau));             % SRC�˲���,��ʽ7.32,��ʽ7.22
%clear RCMbulk
S3 = S2.*Hm.*Hrcm;                                                          % ��λ��ˣ���ʽ7.33
%clear S2 Hm Hrcm

%% �任�������������ʵ�ַ�λѹ���͸�����λУ��
S4 = ifftshift(ifft(ifftshift(S3,2),[],2),2);                               % ������IFFT��ʽ7.34
%clear S3

figure,imagesc(abs(S4));axis image;set(gcf,'Color','w');
title('RD��RC��SRC��һ��RCMC����źŷ���');
xlabel('�����򣨲����㣩');ylabel('��λ�򣨲����㣩');

Hac = exp(-1i*4*pi*R0*f0*D_feta_V/C);                                       % ��λƥ���˲�����ʽ7.34��һ��ָ����
Hpc = exp(1i*(4*pi*Km/C^2).*(1-D_feta_Vref/D_fref_Vref).*(R0./D_feta_V-Rref./D_feta_V).^2); % ��λУ���˲�����ʽ7.34�ڶ���ָ����
S5 = S4.*(Hac'*ones(1,Nr)).*(Hpc'*ones(1,Nr));                              % ��λ��ˣ�ʵ���˲�������ȡH����������
%clear S4 Hac Hpc Km

%% �任��ͼ����
Stt = ifftshift(ifft(ifftshift(S5,1),[],1),1);                              % �źŵķ�λ��IFFT
%clear S5

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

imwrite(Img,'SAR_CSA.bmp','bmp');
