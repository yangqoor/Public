% 2016/10/17
%Liu Yakun 

clc;
clear;
close all;

% �״�ƽ̨����
C = 3e8; %����
Fc = 1e9;%��Ƶ
lambda = C / Fc;%����
Vr = 150;%�����ٶ�
H = 5000;%���и߶�
La = 4;


%��������
Y0 = 10000;%��������Y��
R0 = sqrt(H^2 + Y0^2);%���ߵ������������б��
Length_X = 400;
Length_Y = 800;
Beta = atan(Y0 / H);% �������������
scene_center = [Length_X/2,Y0];

theta = lambda / La;%�������
Lsar = theta * R0;%�ϳɿ׾�����
Tsar = Lsar / Vr;%�ϳɿ׾�ʱ��

% ��ʱ�����
Tr = 2.5e-6;
Kr = 20e12;
alpha_Fsr = 1.2;%  �����������
Fs_org = alpha_Fsr * Kr * Tr;%������ԭʼ������
Tsr_org = 1 / Fs_org;
Rmin = sqrt((Y0 - Length_Y/2)^2 + H^2);%���б��
Rmax = sqrt((Y0 + Length_Y/2)^2 + H^2 + (Lsar/2)^2);%��Զб��
sample_time = 2 * (Rmax - Rmin) / C + Tr;%�������ʱ�䳤��
Nr_org = ceil(sample_time / Tsr_org);% ������������� 
Nr = 2^nextpow2(Nr_org);
% Tsr = sample_time / Nr;% ���º�Ĳ������
% Tf_org = (-Nr / 2:(Nr / 2 -1)) * Tsr_org;%����Ϊ0�Ĳ���ʱ������
% Tf = Tf_org + 2 * R0 / C;% ���������ʱ�����
Tf = linspace(2 * Rmin / C,2 * Rmax / C + Tr,Nr);%��ʱ�����ʱ������
Rf = Tf * C / 2;%б������

% ��ʱ�����
alpha_Fsa = 1.25;
Ka = -2 * Vr^2 / lambda /R0;%��λ����Ƶ��
Fdop = abs(Ka * Tsar);%������Ƶ��
PRF_org = alpha_Fsa * Fdop;%ԭʼPRF
PRT_org = 1 / PRF_org;
Na_org = ceil((Length_X + Lsar) / Vr / PRT_org);%��λ�������
Na = 2^nextpow2(Na_org);%Ϊ����FFT ���µ�
Tsa = (Length_X + Lsar) / Vr / Na;%��λ��������
% PRF = 1 / Tsa;%���յ�PRF
Ts = linspace(-Lsar / 2 / Vr,(Length_X + Lsar / 2) / Vr,Na);
% Ts = (-Na/2:(Na/2-1))*PRT_org;
Ra = Ts * Vr;

Targets = [ 0  -100   1
            100 0     1
            0   100   1
           -100  0    1];
nTargets = size(Targets,1);
Targets(:,1:2) = Targets(:,1:2) + ones(nTargets,1) * scene_center;

DX = La / 2; %��λ��ֱ���
DY = C / (2 * Kr * Tr); %������ֱ���
%�������ͼ
figure;
plot(Targets(:,2),Targets(:,1),'ro');
grid on;
xlabel('�������ף�');
ylabel('��λ��(��)');
axis([Y0-Length_Y/2 Y0+Length_Y/2 0 Length_X]);
title('����������');

%�����ز�
echo = echo_creation(C,H,Y0,lambda,Lsar,Kr,Tr,Tf,Ra,Targets);

x = Y0 + (Tf * C / 2 - R0) / sin(Beta);
y = Ra;

%���ƻز�����
% figure;
% mesh(abs(echo));

%����ѹ��
t = Tf - 2 * R0 / C; 
refr = exp(1i * Kr * pi * t.^2) .* (abs(t) < Tr/2);
signal_compressed = ifty(fty(echo) .* (ones(Na,1) * conj(fty(refr))));
signal_rD = ftx(signal_compressed);
colormap(gray);
figure;
imagesc(x,y,255-abs(signal_compressed));

%RCMC
signal_RCMC = RCMC(signal_rD,lambda,C,Vr,Tsr_org,DY,PRF_org,2);
figure;
imagesc(x,y,255-abs(signal_RCMC));
title('RCMC���ź�');

% ��λ��ѹ��
refa = exp(1i * pi * Ka * Ts.^2) .* (abs(Ts) < Tsar / 2);
final_signal = iftx(ftx(signal_RCMC) .* (conj(ftx(refa)).' * ones(1,Nr)));
figure;
imagesc(x,y,255-abs(final_signal));
title('���յ�Ŀ��');

% %����ѹ��
% tr = Tf - 2*Rmin/C;
% refr = exp(1i*pi*Kr*tr.^2) .* (tr > 0 & tr < Tr);
% signal_comp = ifty(fty(echo) .* (ones(Na,1) * conj(fty(refr))));
% figure;
% imagesc(255-abs(signal_comp));
% 
% %��λѹ��
% ta = Ts;
% refa = exp(1i*pi*Ka*ta.^2) .* (abs(ta) < Tsar/2);
% final_signal = iftx(ftx(signal_comp) .* (conj(ftx(refa)).' * ones(1,Nr)));
% figure;
% imagesc(255-abs(final_signal));
