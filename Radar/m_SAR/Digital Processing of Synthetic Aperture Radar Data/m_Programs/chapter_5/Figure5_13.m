clc
clear
close all
% ��֪����--�����������
R_eta_c_1 = 450;                            % ������б��
R_eta_c_2 = 850;                            % ������б��
R_eta_c_3 = 1250;                           % ������б��
% ��֪����--����λ�����
c  = 3e+8;                                  % ��Ŵ����ٶ�
f0 = 5.3e+6;                                % �״﹤��Ƶ��
Vr = 7100;                                  % ��Ч�״��ٶ�
Ta = 0.64;                                  % Ŀ������ʱ��
Ka = 2095;                                  % ��λ���Ƶ��
theta_r_c = 0*pi/180;                       % б�ӽ�
% ��������
lambda = c/f0;                              % �״﹤������
R0_1 = R_eta_c_1*cos(theta_r_c);            % ���б��
R0_2 = R_eta_c_2*cos(theta_r_c);            % ���б��
R0_3 = R_eta_c_3*cos(theta_r_c);            % ���б��
Delta_f_dop = abs(Ka*Ta);                   % ��λ�źŴ���
t_eta_c_1 = -R_eta_c_1*sin(theta_r_c)/Vr;   % �������Ĵ�Խʱ��
t_eta_c_2 = -R_eta_c_2*sin(theta_r_c)/Vr;   % �������Ĵ�Խʱ��
t_eta_c_3 = -R_eta_c_3*sin(theta_r_c)/Vr;   % �������Ĵ�Խʱ��
% ��������
alpha_a_s = 1;                              % ��λ��������
Fa = alpha_a_s*Delta_f_dop;                 % ��λ����Ƶ��PRF
Na = 2*ceil(Fa*Ta/2);                       % ��λ��������
dt = Ta/Na;                                 % ����ʱ����
df = Fa/Na;                                 % ����Ƶ�ʼ�� 
% ��������
t_eta =  (-Ta/16:dt:Ta/16-dt);              % ��λʱ�����
f_eta =  (-Fa/16:df:Fa/16-df);              % ��λƵ�ʱ���
% �źű��
R_eta_1 = R0_1 + Vr^2*t_eta.^2/(2*R0_1);    % Ŀ��켣
R_eta_2 = R0_2 + Vr^2*t_eta.^2/(2*R0_2);    % Ŀ��켣
R_eta_3 = R0_3 + Vr^2*t_eta.^2/(2*R0_3);    % Ŀ��켣
% �źű��                                          
R_rd_1 = R0_1 + lambda^2*R0_1/(8*Vr^2)*f_eta.^2;    % Ŀ��켣
R_rd_2 = R0_2 + lambda^2*R0_2/(8*Vr^2)*f_eta.^2;    % Ŀ��켣
R_rd_3 = R0_3 + lambda^2*R0_3/(8*Vr^2)*f_eta.^2;    % Ŀ��켣
% ��ͼ                                                                
G = figure();                                                           
set(G,'position',[100,100,800,600]);
plot(R_eta_1,t_eta,'k','LineWidth',2),hold on
plot(R_eta_2,t_eta,'k','LineWidth',2),hold on
plot(R_eta_3,t_eta,'k','LineWidth',2),set(gca,'ydir','reverse')
axis([400 1350,-0.05 +0.05])
xlabel('����(m)'),ylabel('��λʱ��(s)')
sgtitle('ʱ���е�Ŀ��켣','Fontsize',20,'color','k')
% ��ͼ                                                                
G = figure();                                                           
set(G,'position',[100,100,800,600]);
plot(R_rd_1,f_eta,'k','LineWidth',2),hold on
plot(R_rd_2,f_eta,'k','LineWidth',2),hold on
plot(R_rd_3,f_eta,'k','LineWidth',2),set(gca,'ydir','reverse')
axis([400 1350,-110 +110])
xlabel('����(m)'),ylabel('��λƵ��(Hz)')
sgtitle('������������е�Ŀ��켣','Fontsize',20,'color','k')