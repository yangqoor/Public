clc;   close all;clear
%% ---------------------- �״���� ---------------------------------
C                            = 3e8;
Fc                           = 16.2e9;
lambda                       = C/Fc;
Lsar = 2.4;
%% --------------------- Ŀ����뷶Χ ------------------------------
Rmin                          = 30;
Rmax                          = 50;
%% ------------------ ��ʱ�����(��λ��) ----------------------------
Na = 100;
RadarY                        = -Lsar/2+(0:Na-1)*Lsar/Na;                  % �״��˶��켣
%% ------------------ ��ʱ�����(������) ----------------------------
Tr                            = 10e-6;                                     % ������ [s]
Br                            = 200e6;                                     % ���� [Hz]
Kr                            = Br/Tr;                                     % ��Ƶ�� [Hz/s]
Fsr                           = 500e6;                                     % ��ʱ�������� [s]
dt                            = 1/Fsr;

Nr                           = floor((2*(Rmax - Rmin)/C + Tr)*Fsr) ;
NrEffect                     = floor(2*(Rmax - Rmin)/C *Fsr) ;             %�ز�����
tm                           = (0:Nr-1)/Fsr + 2*Rmin/C ;                   %ʱ����(Nr)
r                            = tm(1:NrEffect)*C/2 ;                        %������(NrEffect)
%% ---------------------- �ֱ��� ---------------------------------
DY                            = 0.886*C/2/Br;                              %������ֱ��� [m]
DX                            = 0.886*lambda / (2*Lsar);                   %��λ�Ƿֱ��� [rad]

%% --------------------- Ŀ��������� -----------------------------
Ntarget                                 = 3;                               %Ŀ�����
Ptarget                                 =  [[0  40]; [0 34];[0.6 46]]  ;                       %Ŀ��λ��
%% --------------------- ���ɻز��ź� -----------------------------
Sr = zeros(Na,Nr);
for k=1:1:Ntarget
    Rslow                                = RadarY - Ptarget(k,1);                %�״���Ŀ��ķ�λ�����
    R                                     = sqrt (Rslow.^2 + Ptarget(k,2)^2 );    %�״���Ŀ����б��
    Tdelay                               = 2*R/C;
    Tfast                                = ones(Na,1)*tm -Tdelay'*ones(1,Nr);    %ÿһ�з��ö�Ӧ�ľ���ʱ��,����t������
    phase                                = pi*Kr*(Tfast-Tr/2).^2 - (4*pi/lambda)*R'*ones(1,Nr);
    Sr                                   = Sr+ exp (1i*phase ).*(0<Tfast&Tfast<Tr);
end
Gr = abs(Sr);
figure;
imagesc(r(1:NrEffect) ,RadarY ,abs(Gr(:,(1:NrEffect))));
title('������ѹ��');xlabel('������');ylabel('��λ��');
%% ---------------------- ����ѹ�� --------------------------------
tr                                      = tm - 2*Rmin/C;                   %Ŀ�ľ��ǵõ�Nr����,���뷢���źŲ�������ͬ
Refr                                    = exp(1i*pi*Kr*(tr-Tr/2).^2).*(0<tr&tr<Tr);
F_Refr                                  = fft((Refr));
Srmy                                    = zeros(Na,Nr);
for k1                                 = 1:1:Na
    temp1                              = fft(Sr(k1,:));
    FSrmy                              = temp1.*conj(F_Refr);
    Srmy(k1,:)                         = ifft(FSrmy);
end

%% ------------------------ ��ͼ ---------------------------------
figure;
imagesc(r(1:NrEffect) ,RadarY ,abs(Srmy(:,(1:NrEffect))));
title('����ѹ����');xlabel('������');ylabel('��λ��');

%% ----------------------- ������ ---------------------------------
detax                                    = 0.01;                           % ��λ��������
detay                                    = 0.02;                           % ������������s
XAxis                                    = -1 : detax :1 ;           % ��λ��
YAxis                                    = 30: detay : 50 ;          % ������
N                                        = length(XAxis);                  % ��λ���������
M                                        = length(YAxis);                  % �������������
Y                                        = ones(N,1)*(YAxis);
X                                        = XAxis'*ones(1,M);
f_back                                   = zeros(N,M);                     % ��Ͷ����

Nr_up                                    = 10*Nr;                          %��������ĵ���
tempInterp                               = zeros(1,Nr_up+1);
dtr                                      = dt/10;                          %��������ʱ����
for ii = 1:Na
    temp                                   = fft (Srmy(ii,:));                                 % ȡ�ز�
    tempInterp(1:Nr_up)                    = ifft(fftshift([zeros(1,floor((Nr_up-Nr)/2)),fftshift(temp),zeros(1,Nr_up-Nr-floor((Nr_up-Nr)/2))]));% ������
    R_ij                                   = sqrt(Y.^2+(X - RadarY(ii) ).^2);       % ÿ���������״�ľ���
    t_ij                                   = 2 * R_ij /C;
    t_ij                                   = floor((t_ij-(2*Rmin/C))/dtr)+1;        % ��Rminλ��Ϊ�ο����Ӧ�ڻز��ĵڼ�����
    it_ij                                  = (t_ij>0 & t_ij<=Nr_up);                % ����Ӧ�ĵ㲻������Χ
    t_ij                                   = t_ij.*it_ij+(Nr_up+1)*(1-it_ij);
    f_back                                 = f_back+ tempInterp(t_ij ).*exp(1i*4*pi*R_ij/lambda); %��λ���������Ӵ���
end
figure('Name','BP�㷨�����');
%% -------------------------- ���� -------------------------------
imagesc(YAxis ,XAxis ,abs(f_back));
title('BP�㷨�����');xlabel('������');ylabel('��λ��');

