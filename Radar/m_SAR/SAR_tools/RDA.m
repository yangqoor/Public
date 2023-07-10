function [x] = RDA(La,H,Vr,theta_rc,Y0,Fc,Kr,Tr,alpha_Fsr,alpha_Fsa,delta_x,delta_y,Targets)

C = 3e+8;%����
lambda = C / Fc;%����

Br = Kr * Tr;%��Ƶ�źŴ���
Fsr = alpha_Fsr * Br;%�����������
Tsr = 1.0 / Fsr;%�������ʱ��

theta_gc = atan(H / Y0);%�������Ĳ��ؽ�
R0 = H / sin(theta_gc);%��������б��
Lsar = lambda * R0 / La * cos(theta_rc); %�ϳɿ׾�����
Tsar = Lsar / Vr;

Rmin = sqrt(H^2 + (Y0 - delta_y)^2);%���б��
Rmax = sqrt(H^2 + (Y0 + delta_y)^2 + (Lsar / 2)^2);%�б��
delta_tau = 2 * (Rmax - Rmin) / C;%����ʱ����
Nr = (delta_tau + Tr) / Tsr;%�����������
Nr_update = 2 ^ nextpow2(Nr);% Ϊ��fft����չ����������2���ݡ�
Tf = linspace(2 * Rmin / C,2 * Rmax / C + Tr,Nr_update); %��ʱ�����ʱ���
Rf = Tf * C / 2;%��ʱ����������                   

Ka = 2 * Vr^2 * cos(theta_rc)^3 / lambda / R0; %p93 ��ʽ4.38
Ba = Ka * Tsar; %�����մ���
Fa = alpha_Fsa * Ba;%��λ�����Ƶ��
Tsa = 1.0 / Fa;%��λ�������
Na = (2 * delta_x + Lsar) / Vr / Tsa;%��λ��������
Na_update = 2 ^ nextpow2(Na);%���º�ķ�λ�������
Ts = linspace((-delta_x - Lsar / 2) / Vr,(delta_x + Lsar / 2 )/ Vr,Na_update);%��λ�����ʱ���
Rs = Ts * Vr;%��λ�������Ӧ�ľ���
R_eta = sqrt(R0^2 + Rs.^2);%˲ʱб��

% t = linspace(-Tr/2,Tr/2,Nr_update);
t = linspace(0,Tr,Nr_update);
replica = exp(1i*pi*Kr*t.^2);%�����ź�
figure;
subplot(211);
plot(t,real(replica));
xlabel('ʱ�䣨�룩');
ylabel('�����ź�ʵ��');
grid on;

freq = linspace(-Nr_update/Tr/2,Nr_update/Tr/2,Nr_update);
subplot(212);
plot(freq,abs(fftshift(fft(replica))));
xlabel('Ƶ�ʣ�Hz��');
ylabel('�����ź�Ƶ��');
grid on;

N = size(Targets,1);% ��Ŀ�����
Srev = zeros(Na_update,Nr_update);%��ʼ�������ź�
scene_center = [0 Y0];
Targets(:,1:2) = Targets(:,1:2) + ones(N,1) * scene_center;

figure;
plot(Targets(:,2),Targets(:,1),'ro');
grid on;
xlim([scene_center(2) - delta_y, scene_center(2) + delta_y]);
ylim([-delta_x,delta_x]);
xlabel('�������ף�');
ylabel('��λ����)');
title('����������');

for i = 1:1:N
    sigma = Targets(i,3);%��Ŀ��RCS
    Rx = Vr * Ts - Targets(i,1);%��Ŀ�����״��x������
    Ry = Targets(i,2);%��Ŀ�����״��y������
    R = sqrt(Rx.^2 + Ry^2 + H^2);%��Ŀ���˲ʱб��
    tau = 2 * R / C;%ʱ���ӳ�
    T_mat = ones(Na_update,1) * Tf - tau' * ones(1,Nr_update);%ʱ�����
    phase = 4*pi*R'/lambda * ones(1,Nr_update) + pi*Kr*T_mat.^2;% �����źŵ���λ�����������
    Srev = Srev + sigma * exp(1i*phase) .* (abs(T_mat) >= 0 & abs(T_mat) <= Tr) .* ((abs(Rx) < Lsar / 2)' * ones(1,Nr_update)) ;
end

row = scene_center(2) + (Rf - R0) / sin(theta_gc);
col = Rs;
figure;
[xx,yy] = meshgrid(row,col);
surf(xx,yy,abs(Srev));

ref_comp = fty(ones(Na_update,1)*(replica .* (t >= 0 & t <= Tr)));%.* (ones(Na_update,1)*hamming(Nr_update)');%�����ź�Ƶ��Ӵ�
S_comp = fty(Srev) .* conj(ref_comp);%�����źŲ����FFT֮����
S_comp_ra = ifty(S_comp);%  ����ѹ����任������ʱ��
S_rD = ftx(S_comp_ra);%�任�������������

row = Rf / sin(theta_gc);
col = Rs;
figure;
colormap(gray);
imagesc(row,col,255-abs(S_rD));


