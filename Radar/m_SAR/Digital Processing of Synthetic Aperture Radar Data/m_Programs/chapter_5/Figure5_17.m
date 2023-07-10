clc
clear
close all
%% ��������
%  ��֪����--�����������
R_eta_c = 20e+3;                % ������б��
Tr = 25e-6;                     % ��������ʱ��
Kr = 0.25e+12;                  % �������Ƶ��
alpha_os_r = 1.2;               % �����������
Nrg = 256;                      % �����߲�������
%  �������--�����������
Bw = abs(Kr)*Tr;                % �����źŴ���
Fr = alpha_os_r*Bw;             % �����������
%  ��֪����--����λ�����
c = 3e+8;                       % ��Ŵ����ٶ�
Vr = 150;                       % ��Ч�״��ٶ�
Vs = Vr;                        % ����ƽ̨�ٶ�
Vg = Vr;                        % ����ɨ���ٶ�
f0 = 5.3e+9;                    % �״﹤��Ƶ��
Delta_f_dop = 80;               % �����մ���
alpha_os_a = 1.3;               % ��λ��������
Naz = 256;                      % ��������
theta_r_c = [0,+22.8];          % ����б�ӽ�
t_eta_c = [0,-51.7];            % �������Ĵ�Խʱ��
f_eta_c = [0,+2055];            % ����������Ƶ��
%  �������--����λ�����
lambda = c/f0;                  % �״﹤������
Fa = alpha_os_a*Delta_f_dop;    % ��λ�������
%  ��������
R0 = R_eta_c*cos(theta_r_c(1));                         % ���б��
La = 0.886*2*Vs*cos(theta_r_c(1))/Delta_f_dop;          % ʵ�����߳���
theta_bw = 0.886*lambda/La;                             % ��λ��3dB�������
Trr = Nrg/Fr;                   % ��������ʱ��
Taa = Naz/Fa;                   % Ŀ������ʱ��
Ka = 2*Vr^2/lambda/R0;          % ��λ���Ƶ��
d_t_tau = 1/Fr;                 % �������ʱ����
d_t_eta = 1/Fa;                 % ��λ����ʱ����
d_f_tau = Fa/Nrg;               % �������Ƶ�ʼ��    
d_f_eta = Fa/Naz;               % ��λ����Ƶ�ʼ��
%% ��������
%  ʱ�����                                                    
t_tau = (-Trr/2:d_t_tau:Trr/2-d_t_tau) + 2*R_eta_c/c;   % ����ʱ�����
t_eta = (-Taa/2:d_t_eta:Taa/2-d_t_eta) + t_eta_c(1);    % ��λʱ�����
%  ��������                                                                                                            
[t_tauX,t_eta_Y] = meshgrid(t_tau,t_eta);               % ���ö�ά��������
%% �ź�����
R_eta = R0 + Vr^2*t_eta_Y.^2/(2*R0);                    % ˲ʱб��
A0 = 1;                                                 % ����ɢ��ϵ������
wr = (abs(t_tauX-2*R_eta/c) <= Tr/2);                   % ���������
wa = sinc(0.886*atan(Vg*(t_eta_Y-t_eta_c(1))/R0)/theta_bw).^2;      % ��λ�����
%  �����ź�
srt = A0*wr.*wa.*exp(-1j*4*pi*R0/lambda)...
               .*exp(-1j*pi*Ka*t_eta_Y.^2)...
               .*exp(+1j*pi*Kr*(t_tauX-2*R_eta/c).^2);                                                       
srt_z = A0*wr.*wa.*exp(-1j*4*pi*R0/lambda)...
                 .*exp(-1j*pi*Ka*t_eta_Y.^2)...
                 .*exp(+1j*pi*Kr*(t_tauX-2*R_eta/c).^2);% ��ɨƵ
srt_f = A0*wr.*wa.*exp(-1j*4*pi*R0/lambda)...
                 .*exp(-1j*pi*Ka*t_eta_Y.^2)...
                 .*exp(-1j*pi*Kr*(t_tauX-2*R_eta/c).^2);% ��ɨƵ
%  ����ʱ��-��λƵ��
Srf_rd = fft(srt);
%  ����Ƶ��-��λƵ��
SrF_2d = fft2(srt);
%% ��ͼ
H = figure();
set(H,'position',[100,100,600,600]);      
%  ����ʱ��-��λƵ��
subplot(221),imagesc(abs(Srf_rd)),colorbar,set(gca, 'YDir', 'normal')              
xlabel('������(������)'),ylabel('��λƵ��(������)'),title('(a)RDƵ�׷���');
subplot(222),imagesc(angle(Srf_rd)),set(gca, 'YDir', 'normal')
xlabel('������(������)'),title('(b)RDƵ����λ');
%  ����Ƶ��-��λƵ��                  
subplot(223),imagesc(abs(SrF_2d)),colorbar,set(gca, 'YDir', 'normal')               
xlabel('����Ƶ��(������)'),ylabel('��λƵ��(������)'),title('(c)��άƵ�׷���');
subplot(224),imagesc(angle(SrF_2d)),set(gca, 'YDir', 'normal')
xlabel('����Ƶ��(������)'),title('(d)��άƵ����λ');
sgtitle('ͼ5.17 ��б�ӽ�����µ�����Ŀ��ķ�λƵ��','Fontsize',20,'color','k')