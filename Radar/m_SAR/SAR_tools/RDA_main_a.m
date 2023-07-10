% 2016/10/20
%Liu Yakun
clc;clear;close all;
%�״����,ƽ̨�������Ƶ�źŲ���
C = 3e8; %����
Fc = 1e9;%�����ź���Ƶ
lambda = C / Fc;%�����źŲ���
La = 4;%�״����߷�λ�򳤶�
H = 5000;%�״�ƽ̨���и߶�
V = 150;%�״�����ٶ�
Theta_center = 45 / 180 * pi;%�������������
%----------------------------

R0 = H / sin(Theta_center);%�����������б��
wave_angle = lambda / La;%��λ������ȣ����ȣ�
Lsar = wave_angle * R0;%�ϳɿ׾�����
Ka = -2*V^2/lambda/R0;%��λ���Ƶ��
Tsar = Lsar/V;%�ϳɿ׾�ʱ��

%��������
Xmin = -50;%
Xmax = 50;
Ymin = -300;
Ymax = 300;

%--------------------------------------------
Yc = sin(Theta_center) * R0;%��������y������
Rmin = sqrt(H^2 + (Yc + Ymin)^2);%�������б��
Rmax = sqrt(H^2 + (Yc + Ymax)^2 + (Lsar/2)^2);%�������б��
scene_center = [0,Yc];%
%��ʱ�����
Tr = 2.5e-6;%�������ʱ��
Kr = 2e13;%�������Ƶ��
Fr_alpha = 1.2;%�����������ϵ��

%-----------------------------------------------
Br = Kr * Tr;%�������
Fr = Fr_alpha * Br;%���������Ƶ��
Nr = ceil(((Rmax - Rmin) * 2 / C + Tr) * Fr);%�������������
Nr = 2^nextpow2(Nr);%Ϊ����fft 
Tfast = linspace(2*Rmin/C,2*Rmax/C+Tr,Nr);%���������ʱ������
TFr = (2*(Rmax-Rmin)/C+Tr)/Nr;
% Fr = 1/TFr;
Rr = Tfast * C / 2;%������б�����


%��ʱ�����
Fa_alpha = 1.3;%��λ�������ϵ��

%------------------------------------------------
Fa = Fa_alpha * abs(Ka * Tsar);%��λ�����Ƶ��
PRF = Fa;%�����ظ���������
Na = ceil(((Xmax - Xmin) + Lsar)/V*PRF);%��λ���������
Na = 2^nextpow2(Na);
Tslow = linspace((Xmin-Lsar/2)/V,(Xmax+Lsar/2)/V,Na);%��λ�����ʱ�����
Ra = Tslow * V;%��λ�������Ӧ�ľ������
TFa = ((Xmax-Xmin)+Lsar)/V/Na;
% PRF = 1 / TFa;


%��Ŀ������
Targets = [ 20   -50    1
            20    50    1
             0    0     1
           -20    50    1
           -20   -50    1]; %��ʽΪ�����У��ؾࣩ ���������� ��λ������ RCS
      
%------------------------------------------
Targets(:,1:2) = Targets(:,1:2) + ones(size(Targets,1),1) * scene_center;
DX = La/2;%��λ��ֱ���
DR = C/2/Br;%������ֱ���
DY = DR / sin(Theta_center);

%�ز�����
N = size(Targets,1);%Ŀ������
echo = zeros(Na,Nr); %��ʼ���ز�����
for i = 1:N
    delta_x = Ra - Targets(i,1); %ƽ̨��Ŀ���x������
    delta_y = Targets(i,2);%ƽ̨��Ŀ���y������
    range = sqrt(delta_x.^2 + H^2 + delta_y^2); % ÿ����λ������ �״ﵽĿ���б��
    rcs = Targets(i,3); %��Ŀ��ĺ���ɢ��ϵ��
    tau = ones(Na,1) * Tfast - (2*range / C)' * ones(1,Nr); % ʱ������
    phase = pi * Kr * tau.^2 - 4 * pi / lambda * (range' * ones(1,Nr));%�����ź���λ
    echo = echo + rcs * exp(1i * phase) .* ((abs(delta_x) < Lsar / 2)' * ones(1,Nr)) .* (tau > 0 & tau < Tr);
end

%����ѹ��
t = Tfast - 2*Rmin/C;
refr = exp(1i*pi*Kr*t.^2) .* (t > 0 & t < Tr);
signal_comp = ifty(fty(echo) .* (ones(Na,1)*conj(fty(refr))));%�ο��źŲ����DFT ȡ����



%�����㶯У��
signal_rD = ftx(signal_comp);
win = waitbar(0,'��������ֵ');
for i = 1:Na
    for j = 1:Nr
        delta_R = (1/8)*(lambda/V)^2*(R0+(j-Nr/2)*C/2/Fr)*((j-Nr/2)/Nr*PRF)^2;%�����㶯��
        RCM = delta_R / DY;%�㶯�˶��ٸ����뵥Ԫ
        delta_RCM = RCM - floor(RCM);%С������
        if round(RCM + j) > Nr
            signal_rD(i,j) = signal_rD(i,Nr/2);
        else
            if delta_RCM < 0.5
                signal_rD(i,j) = signal_rD(i,j+floor(RCM));
            else
                signal_rD(i,j) = signal_rD(i,j+ceil(RCM));
            end
        end
    end
        waitbar(i/Na);
end
close(win);
signal_rcm = iftx(signal_rD);   


%��λ��ѹ��
ta = Tslow;
refa = exp(1i*pi*Ka*ta.^2).*(abs(ta) < Tsar/2);
final_signal = iftx(ftx(signal_rcm) .* (conj(ftx(refa)).' * ones(1,Nr)));
%��ͼ

%��Ŀ������
figure;
plot(Targets(:,2),Targets(:,1),'ro');
grid on;
axis([Yc+Ymin Yc+Ymax Xmin Xmax]);
xlabel('�������ף�');
ylabel('��λ���ף�');
title('�����е�Ŀ��λ��');

figure;
subplot(211);
colormap(gray);
imagesc(Rr,Ra,255-abs(signal_comp));
xlabel('�������ף�');
ylabel('��λ���ף�');
title('����ѹ������ź�');
subplot(212);
colormap(gray);
imagesc(Rr,Ra,255-abs(signal_rcm));
xlabel('�������ף�');
ylabel('��λ���ף�');
title('RCMC����ź�');



figure;
colormap(gray);
xx = Yc + (Rr-R0)/sin(Theta_center);
yy = Ra;
imagesc(xx,yy,255-abs(final_signal));
xlabel('�������ף�');
ylabel('��λ���ף�');
title('���յĵ�Ŀ��');

