%2016��10��31
%Liu Yakun
clc,clear,close all;

C = 3e8;%����
Fc = 1e9; %�ز�Ƶ��
lambda = C / Fc;%����
H = 5000;%�״�߶�
Theta = 2 / 180 * pi;%б�ӽ�
V = 150;%�״��ٶ�
La = 4;%�״﷽λ�����߳���
wave_width = lambda / La;%�������
Tr = 5e-6;%�������ʱ��
Br = 60e6;%�������
Kr = Br / Tr;%�������Ƶ��

Y0 = 5e3;%��������Y�����
Ymin = Y0 -100;
Ymax = Y0 + 100;
Xmin = 0;
Xmax = 50;

R0 = sqrt(H^2 + Y0^2);%���б��
Rc = R0 / cos(Theta);%�������Ĵ�Խʱ��б��
Lsar = wave_width * Rc / cos(Theta);%�ϳɿ׾�����
Tsar = Lsar / V;%�ϳɿ׾�ʱ��

Targets = [20   -20    1
           20    20    1
           40    -40   1
           40    40    1];
scene_center = [0   Y0];%�����ο�λ��
Targets(:,1:2) = Targets(:,1:2) + ones(size(Targets,1),1) * scene_center;

Rmin = sqrt(H^2 + Ymin^2);%�������״��������
Rmax = sqrt(H^2 + Ymax^2 + (Lsar/2)^2);%�������״���Զ����
% alpha_fsr = 1.2;%�����������ϵ��
% alpha_fsa = 1.3;%��λ�������ϵ��
fs = Br;%���������Ƶ��
Nr = (2 * (Rmax - Rmin) / C + Tr) * fs;%�������������
Nr = 2^nextpow2(Nr);
fs = Nr / (2 * (Rmax - Rmin) / C + Tr);
alpha_fsr = fs / Br;
% alpha_fsr = Nr / (2 * (Rmax - Rmin) / C + Tr) / Br;
tf = linspace(2 * Rmin / C,2 * Rmax / C + Tr,Nr);%�������ʱ������
Ts = 1 / fs;

Ka = -2 * V^2 * cos(Theta)^3 / lambda / R0;%��λ���Ƶ��
Ba = round(abs(Ka * Tsar));%��λ�������Ƶ��
PRF = Ba;%�����ظ�Ƶ��
Na = (Xmax - Xmin + Lsar) / V * PRF;%��λ���������
Na = 2^nextpow2(Na);
alpha_fsa = Na / 
ts = linspace((Xmin - R0 * tan(Theta) - Lsar / 2)/V,(Xmax + Lsar/2)/V,Na);%��λ����ʱ������

Ntar = size(Targets,1);
echo = zeros(Na,Nr);

for i = 1:Ntar
    rcs = Targets(i,3);
    delta_x = abs(ts*V - Targets(i,1));
    delta_y = Targets(i,2);
    delta_z = H;
    
    R = sqrt(delta_x.^2 + delta_y^2 + delta_z^2);%˲ʱб��
    tau = 2 * R / C;%б���Ӧ�Ĵ���ʱ��
    delta_t = ones(Na,1) * tf - tau.' * ones(1,Nr);
    phase = -4*pi/lambda*R.'*ones(1,Nr) + Kr*pi*delta_t.^2;
    echo = echo + rcs * exp(1i*phase) .* (delta_t > 0 & delta_t < Tr) .* ((abs(delta_x)<(Lsar/2 + R0*tan(Theta))).'*ones(1,Nr));
end

% figure;
% colormap(gray);
% imagesc(255-abs(echo));

%������ѹ
t = tf - 2 * Rmin / C;
ref_r = exp(1i*pi*Kr*t.^2) .* (t < Tr & t > 0);
signal_comp = ifty(fty(echo) .* (ones(Na,1) * conj(fty(ref_r))));
figure;
colormap(gray);
imagesc(255-abs(signal_comp));

%RCMC
signal_RD = ftx(signal_comp);
win = waitbar(0,'��������ֵ');
for i = 1:Na
    for j = 1:Nr
        rcm = 1/8*(lambda/V)^2*(tf(j)*C/2)*(-Ka*ts(i))^2;
        nrcm = 2*rcm/C/Ts;
        delta_nrcm = nrcm - floor(nrcm);
        
        if round(nrcm)+j > Nr
            signal_RD(i,j) = signal_RD(i,Nr/2);
        else
            if delta_nrcm < 0.5
                signal_RD(i,j) = signal_RD(i,j+floor(nrcm));
            else
                signal_RD(i,j) = signal_RD(i,j+ceil(nrcm));
            end
        end
    end
    waitbar(i/Na);
end
close(win);

signal_rcmc = iftx(signal_RD);

figure;
colormap(gray);
imagesc(255-abs(signal_rcmc));