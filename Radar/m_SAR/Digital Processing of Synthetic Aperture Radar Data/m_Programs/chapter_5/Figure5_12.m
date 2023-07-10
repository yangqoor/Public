clc
clear
close all
% ��֪����--�����������
R_eta_c = 850e+3;                       % ������б��
% ��֪����--����λ�����
Vr = 7100;                              % ��Ч�״��ٶ�
Ta = 0.64;                              % Ŀ������ʱ��
Ka = 2095;                              % ��λ���Ƶ��
theta_r_c = -0.3*pi/180;                % б�ӽ�
% ��������
Delta_f_dop = abs(Ka*Ta);               % ��λ�źŴ���
t_eta_c = -R_eta_c*sin(theta_r_c)/Vr;   % �������Ĵ�Խʱ��
% ��������
alpha_a_s = 1;                          % ��λ��������
Fa = alpha_a_s*Delta_f_dop;             % ��λ����Ƶ��PRF
Na = 2*ceil(Fa*Ta/2);                   % ��λ��������
dt = Ta/Na;                             % ����ʱ����
df = Fa/Na;                             % ����Ƶ�ʼ�� 
% ��������
t_eta =  (-Ta/2:dt:Ta/2-dt) + t_eta_c;  % ��λʱ�����
% �źű��
R_eta = R_eta_c -...
        Vr*sin(theta_r_c)*(t_eta-t_eta_c) +...
        (1/2)*(Vr^2*cos(theta_r_c)^2/R_eta_c)*(t_eta-t_eta_c).^2;   % ˲ʱб��չ��ʽ
%{
R_eta = sqrt(R0^2 + Vr^2*eta^2) % ˲ʱб���˫������ʽ                        
R_eta = R0 + Vr^2*eta^2/(2*R0)  % ˲ʱб�����������ʽ                
R_eta = R_eta_c -...
        Vr^2*eta_c/R_eta_c*(eta-eta_c) +...
        (1/2)*(Vr^2*cos(theta_r_c)^2/R_eta_c)*(eta-eta_c).^2;
R_eta = R_eta_c -...
        Vr*sin(theta_r_c)*(eta-eta_c) +...
        (1/2)*(Vr^2*cos(theta_r_c)^2/R_eta_c)*(eta-eta_c).^2;
%}
RCM_1 = -Vr*sin(theta_r_c)*(t_eta-t_eta_c+Ta/2);                    % �����㶯���Է���
RCM_2 = (1/2)*(Vr^2*cos(theta_r_c)^2/R_eta_c)*(t_eta-t_eta_c).^2;   % �����㶯���η���
RCM_all = RCM_1 + RCM_2;                                            % �����㶯����
% ��ͼ                                                                
H = figure();
set(H,'position',[100,100,800,600]);
plot(RCM_1,t_eta,'k--','LineWidth',2),hold on
plot(RCM_all,t_eta,'r','LineWidth',2),set(gca,'ydir','reverse')
axis([-5 35 0 1.2])
xlabel('�����㶯(m)'),ylabel('��λʱ��(s)')
line([0,0],[0,1.2],'Color','r','LineStyle','--')
line([3,3],[0,1.2],'Color','r','LineStyle','--')
arrow([3,0.2],[27,0.2],'Color','k','Linewidth',1);
arrow([27,0.2],[3,0.2],'Color','k','Linewidth',1);
text(15,0.15,'�ܵľ����㶯','FontSize',14,'Color','black','HorizontalAlignment','center')
arrow([0,0.3],[3,0.3],'Color','b','Linewidth',1);
arrow([3,0.3],[0,0.3],'Color','b','Linewidth',1);
text(1.5,0.25,'���η���','FontSize',14,'Color','blue','HorizontalAlignment','center')
line([24,24],[0,1.2],'Color','r','LineStyle','--')
line([27,27],[0,1.2],'Color','r','LineStyle','--')
arrow([24,0.95],[27,0.95],'Color','b','Linewidth',1);
arrow([27,0.95],[24,0.95],'Color','b','Linewidth',1);
text(25.5,1,'���η���','FontSize',14,'Color','blue','HorizontalAlignment','center')
arrow([10,0.4],[5,0.4],'Color','k','Linewidth',1);
text(13,0.4,'Ŀ��켣','FontSize',14,'Color','black','HorizontalAlignment','center')
arrow([17,0.9],[22,0.9],'Color','k','Linewidth',1);
text(14,0.9,'���Է���','FontSize',14,'Color','black','HorizontalAlignment','center')
sgtitle('ͼ5.12 �����㶯�����Է����Ͷ��η���','Fontsize',20,'color','k')