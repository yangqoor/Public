%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Project:            Simulation.m                                           %%
%%  Author:             BoBo Li                                                %%
%%  Date  :             September 19th,2004                                    %%
%%  Functionality:      ģ�����ԭʼ����
%%  ��ע  :                                                                    %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear ; % ������еı���
clc; % ����
close all; % �ر����е�ͼ�δ���

cj = sqrt(-1);
pi2 = 2 * pi;
c = 3e8;

%
%% System Parameters
RanNum = 1024;
AziNum = 1024;
PRF = 100; % �����ظ�Ƶ��
Va = 100; % ��λ���ٶ�
R0 = 6e3; % ���������ĵ���̾���
%
%% fast time parameters
Klfm = 6e12; % ��Ƶб��
Tp = 6e-6; % Pulse duration time
BandWidth = Tp * Klfm;
SapRate = 50e6; % ������
flag1 = SapRate / BandWidth %�����ʱ�����ڴ���
delta_tr = 1 / SapRate; % �������

Tr = delta_tr * [0:RanNum - 1]; % ��ʱ��
X0 = 1000; % ��������Ϊ2X0
Rmin = R0 - X0; %
Tr_start = 2 * Rmin / c;
Tr = Tr_start + Tr;
Range = Tr * c / 2;
lambda = 0.3;
fc = c / lambda;
wc = pi2 * fc;
wcm = wc - 0.5 * Tp * Klfm;

%ptr = exp(cj*wcm+cj*pi*Klfm*Tr.^2).*(Tr>0 & Tr<Tp ); % pulse in range time
%plot(real(ptr));

%
%% slow time parameters
Fk = -2 * Va^2 / (lambda * R0); % �����յ�Ƶб��
Ts = 6; % �ϳɿ׾�ʱ��
DoBandWidth = abs(Fk) * Ts; % Doppler BandWidth
flag2 = PRF / DoBandWidth % flag2 > 1
PRI = 1 / PRF; % �����ظ����
Ta = PRI * (-AziNum / 2:AziNum / 2 - 1);

Azimuth = Va * Ta; %��λ
L = 0.5 * Ts * Va; % ��׾�

%Td = 2*Rt/c;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%        SIMULATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ����ʹ�õ��Ǹ�Ŀ���볡�����ĵ���Ծ���

ntargets = 1; % ��Ŀ��ĸ���������ѡ�����
TARGETS = zeros(2, 9);
DX = 0.5 * c * 1 / BandWidth;
DY = Va * 1 / DoBandWidth;
CENTER = [R0 0];
%
%% ��Ŀ������������ɢ��ϵ��
TARGETS(:, 1) = [0 0].'; sigma(1) = 1;
TARGETS(:, 2) = [-50 * DX 50 * DY].'; sigma(2) = 2;

TARGETS = TARGETS + CENTER.' * ones(1, 9);

%
%% Generating the raw data
Sr = zeros(AziNum, RanNum);

for i = 1:ntargets
    Rt = sqrt(TARGETS(1, i).^2 + Va^2 * (Ta - TARGETS(2, i) / Va).^2); % ����ʱ��仯��б��
    Rt = Rt.';
    Td = ones(AziNum, 1) * Tr - 2 * Rt / c * ones(1, RanNum);
    Sr = Sr + sigma(i) * exp(cj * wcm * Td + cj * 0.5 * pi2 * Klfm * Td.^2) .* (abs(Td) < Tp / 2) .* ((abs(Azimuth - TARGETS(2, i)) < L).' * ones(1, RanNum)); % recieved signal
end

Sr = Sr .* (ones(AziNum, 1) * exp(-cj * wc * Tr)); % ȥ��Ƶ

%
%% visualize the raw data
figure(1);
%G=abs(Sr);
G = abs(real(Sr));
xg = max(max(G)); ng = min(min(G)); cg = 255 / (xg - ng);
colormap(gray(256));
image(Range, Azimuth, 255 - cg * (G - ng));
title('the raw data');
xlabel('Range , meters');
ylabel('Azimuth ,meters');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%           PROCESSING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
delta_Fre_R = SapRate / RanNum; % �������Ƶ�ʼ��
Fre_R = delta_Fre_R * (-RanNum / 2:RanNum / 2 - 1); % �������Ƶ��
FSr_R = fty(Sr); % ������Ƶ��

delta_Fre_A = PRF / AziNum; % ��λ���Ƶ�ʼ��
Fre_A = delta_Fre_A * (-AziNum / 2:AziNum / 2 - 1); % ��λ���Ƶ��
FSr_A = ftx(Sr); % ��λ��Ƶ��

%
%% ����ѹ��
% ������Ĳο�����
Tr_ref = delta_tr * (-RanNum / 2:RanNum / 2 - 1);
Sr_ref_R = exp(cj * 0.5 * pi2 * Klfm * Tr_ref.^2) .* (abs(Tr_ref) < Tp / 2);
FSr_ref_R = fty(Sr_ref_R);
MFSR = ifty(FSr_R .* (ones(AziNum, 1) * conj(FSr_ref_R))); % Matched Filtered Signal In Range

figure(2);
G = abs(MFSR);
xg = max(max(G)); ng = min(min(G)); cg = 255 / (xg - ng);
colormap(gray(256));
image(255 - cg * (G - ng));
title('the compressed signal in range');
xlabel('Range , meters');
ylabel('Azimuth ,meters');

%
%% �����㶯У��
FFMFSR = fty(ftx(MFSR)); % Fourier Transform of MFSR
Rf = sqrt(R0^2 + Va^2 * (Fre_A / Fk).^2).'; % ���뷽�̣��Ա���ΪƵ�ʣ�
RMCS = ifty(FFMFSR .* exp(cj * 2 * (Rf - R0) / c * pi2 * Fre_R));

figure(3);
G = abs(RMCS);
xg = max(max(G)); ng = min(min(G)); cg = 255 / (xg - ng);
colormap(gray(256));
image(Range, Fre_A, 255 - cg * (G - ng));
title(' Range Migration Corrected Signal');
xlabel('Range , meters');
ylabel('Azimuth Frequency ,Hz');

%
%% ��λѹ��
%  ��λ��Ĳο�����
Ta_ref = Ta;
Sr_ref_A = exp(cj * 0.5 * pi2 * Fk * Ta_ref.^2) .* (abs(Ta_ref) < Ts / 2);
FSr_ref_A = fty(Sr_ref_A);
FSr_ref_A = FSr_ref_A.';
MFSA = iftx(RMCS .* (conj(FSr_ref_A) * ones(1, RanNum))); % Matched Filtered Signal In Azimuth

figure(4);
G = abs(MFSA);
xg = max(max(G)); ng = min(min(G)); cg = 255 / (xg - ng);
colormap(gray(256));
%image(255-cg*(G-ng));
mesh(255 - cg * (G - ng));
title('the compressed signal in azimuth');
xlabel('Range , meters');
ylabel('Azimuth ,meters');

%Sr = exp(cj*wcm*Tr+cj*0.5*pi2*Klfm*Tr.^2).*( 0 <= Tr & Tr <= Tp ); % recieved signal
%plot(real(Sr));
figure(5);
plot(Tr, real(Sr(500, :)));
xlabel('Range Time/ second');
ylabel('Real Part ');
title('Signal in Range Time');
figure(6);
plot(Azimuth, real(Sr(:, 300)));
xlabel('Azimuth / Meters');
ylabel('Real Part ');
title('Signal in Azimuth Time');
figure(7);
plot(Fre_R, abs(FSr_R(512, :)));
xlabel('Frequency , meters');
ylabel('Magnitude');
title('the spectrum of range signal ');
figure(8);
plot(Fre_A, abs(FSr_A(:, 300)));
xlabel('Frequency ,Hz');
ylabel('Magnitude');
title('the spectrum of azimuth signal ');
figure(9);
plot(Range, abs(MFSR(512, :)));
xlabel('range Meters');
ylabel('Azimuth/Meters');
title('Range Compressed Signal');
figure(10);
plot(Azimuth, real(MFSR(:, 300)));
xlabel('Azimuth / Meters');
ylabel('Real Part ');
title('Signal in Azimuth Time');

% beep = 0.1 * [0 1 2 3 4 5 6 7 8 9];
% beep = repmat(beep, 1, 300);
% beep = [beep, zeros(1, 4000), beep];
% sound(beep);
