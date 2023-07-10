%=========================================================
% Author: Liu Yakun
% Date: 20,Sep,2016
% Program Name: The image of dot's targets in SAR with RDA
%=========================================================

clc,clear,close all;

%���������������������������������ã�������������������������������������
C = 3e+8;       %����
fc = 1e9;     %�����ź�����Ƶ��
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
%             50 -200 0   1
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
    
    %==============�����źŹ۲�=========================================
%     figure;
%     [x,y] = meshgrid(tf * C / 2 / sin(Theta_d),ts * V);
%     surf(x,y,abs(Sr));
%     xlabel('������ �� CT ��m��');
%     ylabel('��λ�� �� AT ��m��');
%     zlabel('�����źŷ���');
%     title('�����ź�ǿ��');

end

%====================������ѹ������������������������������������������������������
ref_h = exp(1i * pi * Kr * tf_ideal .^ 2) .* (abs(tf_ideal) < Tr / 2);  %��ѹ�ο�����
ref_h = ref_h .* hamming(Nr).';                        %�Ӻ�����
ref_H = fty(ones(Na,1) * ref_h);                       %�任��Ƶ��
Sr_comp_ra = ifty(fty(Sr) .* conj(ref_H));             %Ƶ�����
Sr_comp_rA = ftx(Sr_comp_ra);                          %��λ����Ҷ�任����������
Sr_RD = Sr_comp_rA;
%�鿴��ѹ����ź�
% figure;
% plot(Scene_center(2) + (tr - R0) / sin(Theta_d),abs(Sr_comp_rA(1,:)));
% title('ѹ��������ݳ��');

%���������������������������������㶯У��������������������������������������������������
%����ڲ�ֵ
% win = waitbar(0,'��������ֵ');
% 
% for m = 1 : 1 : Na
%     for n = 1 : 1 : Nr
%         delta_R = 1 / 8 * (lambda / V) ^ 2 * (R0 + (n- Nr / 2) * Ts * C / 2) * ((m- Na / 2) / Na * PRF) ^ 2;
%         RMC = 2 * delta_R / C * Fs;
%         delta_RMC = RMC - floor(RMC);
%         
%         if n + round(RMC) > Nr
%             Sr_comp_rA(m,n) = Sr_comp_rA(m,Nr / 2);
%         else
%             if delta_RMC >= 0.5
%                 Sr_comp_rA(m,n) = Sr_comp_rA(m,n + ceil(RMC));
%             else
%                 Sr_comp_rA(m,n) = Sr_comp_rA(m,n + floor(RMC));
%             end
%         end
%     end
%     waitbar(m/Na);
% end
% close(win);

%sinc��ֵ
k = 4;
win = waitbar(0,'sinc��ֵ');
for m = 1 : 1 : Na
    for n = 1 : 1 : Nr
        delta_R = 1 / 8 * (lambda / V) ^ 2 * (R0 + (n- Nr / 2) * Ts * C / 2) * ((m- Na / 2) / Na * PRF) ^ 2;
        RMC = 2 * delta_R / C * Fs;
        delta_RMC = RMC - floor(RMC);
        
        for i = -k / 2 : k / 2 - 1;
            Sr_comp_rA(m,n) = Sr_comp_rA(m,n) + Sr_comp_rA(m,n) .* sinc(n + delta_RMC);
        end;
    end;
    waitbar(m / Na);
end;
close(win);


Sr_RMC = iftx(Sr_comp_rA);

%=====================��λ ѹ��������������������������������������������

ref_a = exp(1i * pi * Ka * ts .^ 2) .* (abs(ts) < Tsar / 2);
Sr_SAR = iftx(ftx(Sr_RMC) .* conj(ftx(ref_a)' * ones(1,Nr)));
% plot(abs(Sr_SAR));

%=======================��ͼ������������������������������������������

%================��ʾ������====================================
figure;
subplot(211);
plot(Targets(:,2),Targets(:,1),'rO');
grid on;
axis([Scene_center(2) + Y_min Scene_center(2) + Y_max Scene_center(1) + X_min Scene_center(1) + X_max]);
xlabel('������AT ��m��');
ylabel('��λ��CT ��m��');
title('Ŀ�곡������');

%�ز��ź�
colormap(gray);
subplot(212);
row = Scene_center(2) + (tr - R0) / sin(Theta_d);
col = ts * V;
imagesc(row,col,255 - abs(Sr));
xlabel('������AT ��m��');
ylabel('��λ��CT ��m��');
grid on;
title('�ز��ź�');

%������ѹ֮�������
figure;
colormap(gray);

subplot(211);
imagesc(row,col,255 - abs(Sr_RD));
xlabel('������AT ��m��');
ylabel('��λ��CT ��m��');
grid on;
title('������ѹ֮������ݣ�RCMC֮ǰ��');

subplot(212);
imagesc(row,col,255 - abs(Sr_RMC));
xlabel('������AT ��m��');
ylabel('��λ��CT ��m��');
grid on;
title('������ѹ֮������ݣ�RCMC֮��');

figure;
colormap(gray);
imagesc(row,col,255 - abs(Sr_SAR));
xlabel('������AT ��m��');
ylabel('��λ��CT ��m��');
grid on;
title('��λѹ��֮�������');

