%=========================================================
% Author: Liu Yakun
% Date: 29,Sep,2016
% Program Name: The image of dot's targets in SAR with CSA
%=========================================================

clc,clear,close all;

%���������������������������������ã�������������������������������������
C = 3e+8;       %����
fc = 5.3e9;     %�����ź�����Ƶ��
lambda = C / fc; %����
Theta_r = 0 / 180 * pi; %б�ӽ�
H = 5000;                  %����ƽ̨�߶�
Platform_center = [0,0,H]; %ƽ̨����
Theta_d = 45 / 180 * pi;   %���ӽ�
Yc = H * tan(Theta_d);     %���������䣩����Y��
Scene_center = [0,Yc,0];   %������������
R0 = sqrt(sum((Platform_center - Scene_center).^2));   %����ƽ̨���������ĵľ���
delta_X = 200;
delta_Y = 500;
X_min = -delta_X / 2;
X_max = delta_X / 2;
Y_min = -delta_Y / 2;
Y_max = delta_Y / 2;

%������������������������LFM �źŲ�������������������������������������������
Tr = 2.5e-6;       %�������ʱ��
Kr = 2e+13;        %�����Ƶ��
Br = Tr * Kr;      %�����źŴ���

%�״����ܲ���
V = 150;                   %�����ٶ�
La = 4;                    %���߷�λ�򳤶�
DY = C / Br / 2;           %������ֱ���
DX = La / 2;               %��λ��ֱ���
Lsar = lambda * R0 / La;   %�ϳɿ׾�����
Tsar = Lsar / V;           %�ϳɿ׾�ʱ��

%������������������������ʱ����� �����򣽣�������������������������������������

Fr_rate = 1.2;     %�����������ϵ��
Fs = round(Br * Fr_rate); %���������Ƶ��
Ts = 1 / Fs;
Rmin = sqrt(H^2 + (Yc + Y_min)^2);                 %���б��
Rmax = sqrt(H^2 + (Yc + Y_max)^2 + (Lsar / 2)^2);  %��Զб��
Nr = ceil((2 * (Rmax - Rmin) / C + Tr) / Ts);      %��ʱ���������
Nr = 2 ^ nextpow2(Nr);                             %��չ��2���� ����fft����
Ts = (2 * (Rmax - Rmin) / C + Tr) / Nr;
Fs = ceil(1 / Ts);                                 %����Fs
tf_ideal = [-Nr / 2 : Nr / 2 - 1] * Ts;              %�����ʱ�����ʱ��
% tf = tf_ideal + 2 * R0 / C;                        %ʵ�ʿ�ʱ�����ʱ��
tf = linspace(2 * Rmin / C,2 * Rmax / C + Tr,Nr);  %ʵ�ʿ�ʱ�����ʱ��
tr = tf * C / 2;                                       %��ʱ�������Ӧ�ľ���

%������������������������ʱ����� ��λ�򣽣�����������������������������������������
PRF_rate = 1.25;            %��ʱ�������ϵ��
Ka = -2 * V^2 / lambda / R0; %��λ��Ƶ��
Ba = abs(Ka * Tsar);              %�����մ���
PRF = round(PRF_rate * Ba);  %�����ظ�����Ƶ��
PRT = 1 / PRF;               %�����ظ���������
Na = ceil((X_max - X_min + Lsar) / V / PRT);  %��ʱ���������
Na = 2 ^ nextpow2(Na);                        %��չ��2���� ����fft����
PRT = (X_max - X_min + Lsar) / V / Na;
PRF = ceil(1 / PRT);                           %����PRF
ts = [-Na / 2 : Na / 2 - 1] * PRT;                  %��ʱ�����ʱ��
ta = ts * V;                                  %��ʱ�������Ӧ�ľ���

%=================Ŀ��������ã�������������������������������������������������
Targets = [ 0   0   0   1
           -50 -200 0   1
            50 -200 0   1
            20  200 0   1
           -20  200 0   1];    %��x,y,z,rcs]  �������
Ntar = size(Targets,1);
Targets(:,1:3) = Targets(:,1:3) + ones(Ntar,1) * Scene_center; %ʵ������


%====================�ز���������������������������������������������������������
Sr = zeros(Na,Nr);
for i = 1:1:size(Targets,1)
    
    sigma = Targets(i,4);                                  %��ǰĿ���RCS
    x_range = ts * V - Targets(i,1);
    y_range = Platform_center(2) - Targets(i,2);   
    z_range = Platform_center(3) - Targets(i,3);
    range = sqrt(x_range .^ 2 + y_range ^ 2 + z_range ^ 2); %��ʱ���Ӧ��˲ʱб��
    tau = 2 * range / C;                                    %��ǰб���Ӧ��ʱ���ӳ�
    Dfast = ones(Na,1) * tf - tau' * ones(1,Nr);            %ʱ�����
    phase = pi * Kr * Dfast .^ 2 + 4 * pi / lambda * range' * ones(1,Nr);  %�����ź���λ
    Sr = Sr + exp(1i * phase) .* (abs(Dfast) < Tr / 2) .* ((abs(x_range) < Lsar / 2)' * ones(1,Nr)); %�����ź�
    
end

%====================CS����==============================================
fr = linspace(-Fs/2,Fs/2,Nr);       %������Ƶ��
fa = linspace(-PRF/2,PRF/2,Na);     %��λ��Ƶ��
R_ref = R0;                         %����������̾���
R = tr;                             %������б��
D = 1 ./ sqrt(1 - (lambda * fa ./ 2 / V).^ 2);
alpha = 1 ./ D - 1;
Km = Kr ./ (1 - Kr * lambda * R_ref * (fa .^ 2) / 2 / V^2 / fc^2 ./ D.^3);
tau = ones(Na,1) * tf - (2 * R_ref / C ./ D)' * ones(1,Nr); 
Ssc = exp(1i * pi * (Km .* alpha)'* ones(1,Nr) .* tau.^2);  %CS��귽��

Sr_rA = ftx(Sr);                       % �任�������������  ��һ��
Sr_sc = Sr_rA .* Ssc;                  %���Ա�귽��        �ڶ���

Sr_RA = fty(Sr_sc);                    %�任����άƵ��      ������
rangeMod_phase = pi * (D ./ Km)' * ones(1,Nr) .* (ones(Na,1) * fr.^2);  %���������λ   
cs_bulk_phase = 4 * pi * R_ref / C * alpha' * ones(1,Nr) .* (ones(Na,1) * fr); %һ��RCM��λ
Sr_RA_cor = Sr_RA .* exp(1i * (rangeMod_phase + cs_bulk_phase));  %��λ���    ���Ĳ�

Sr_rA_1 = ifty(Sr_RA_cor);   %�任�������������      ���岽
dop_phase = 4 * pi / lambda * (ones(Na,1) * R) .* (D' * ones(1,Nr)); %��λѹ��
phase_cor = 4 * pi / C^2 * (Km .* ((1 - D)./D .^ 2))' * ones(1,Nr) .* (ones(Na,1) * (R_ref - R) .^ 2); %������λУ��
Sr_rA_cor = Sr_rA_1 .* exp(1i * (dop_phase + phase_cor));   % ��λ���  ������
% Sr_rA_cor = Sr_rA_1 .* exp(1i * dop_phase);   % ��λ���  ������
Sr_ra = iftx(Sr_rA_cor);  %�任��ʱ��  ���߲�

%========================��ͼ============================================

%================��ʾ������====================================
figure;
subplot(211);
plot(Targets(:,2),Targets(:,1),'rO');
grid on;
axis([Scene_center(2) + Y_min Scene_center(2) + Y_max Scene_center(1) + X_min Scene_center(1) + X_max]);
xlabel('������AT ��m��');
ylabel('��λ��CT ��m��');
title('Ŀ�곡������');

% figure;
% imagesc(abs(Sr_rA));
% title('�����������-ԭʼ�ź�');
% 
% figure;
% imagesc(abs(Sr_sc));
% title('�����������-�����ź�');
% 
% figure;
% imagesc(abs(Sr_RA));
% title('��άƵ��-�����ź�');
% 
% figure;
% imagesc(abs(Sr_RA_cor));
% title('��άƵ��-����RCM��');
% 
% figure;
% imagesc(abs(Sr_rA_1));
% title('�����������-����RCM��');
% 
% figure;
% imagesc(abs(Sr_rA_cor));
% title('�����������-��λѹ������λУ����');
figure;
mesh(abs(Sr_ra));

figure;
imagesc(abs(Sr_ra));
title('ʱ��-��Ŀ��');
