clc
clear
close all
% ��֪����                           
Ta = 64;                        % �������ʱ��
Ka = -1.56e-2;                  % ��λ���Ƶ��
% ��������
Delta_f_dop = abs(Ka*Ta);       % ��λ�źŴ���
% ��������
alpha_as = 1;                   % ��λ��������
Fa = alpha_as*Delta_f_dop;      % ��λ����Ƶ��PRF
N = 2*ceil(Fa*Ta/2);            % ��λ��������
dt = Ta/N;                      % ����ʱ����
df = Fa/N;                      % ����Ƶ�ʼ��
% ��������
t1 = -Ta/2:dt:Ta/2-dt;          % ʱ�����
f1 = -Fa/2:df:Fa/2-df;          % Ƶ�ʱ���
t2 = -3*Ta/4:dt:Ta/4-dt;        % ʱ�����
f2 = -3*Fa/4:df:Fa/4-df;        % Ƶ�ʱ���
n = 0:N-1;                      % ��������
% �źű��
st1 = exp(1j*pi*Ka*t1.^2);      % ��λChirp�ź�
st2 = exp(1j*pi*Ka*t2.^2);      % ��λChirp�ź�
omega_a = sinc(1.5*t1/Ta).^2;   % ˫�����߲�������ͼ
omega_a_nor = abs(omega_a)./max(abs(omega_a));      % ��һ��
omega_a_log = 20*log10(omega_a_nor);                % ������
st1 = omega_a.*st1;             % ���߷���ͼ���Ƶķ�λChirp�ź�
st2 = omega_a.*st2;             % ���߷���ͼ���Ƶķ�λChirp�ź�
% �źű��                    
Sf1 = fft(st1);                 % Chirp�ź�Ƶ�ױ��ʽ
Sf2 = fft(st2);                 % Chirp�ź�Ƶ�ױ��ʽ
% ��ͼ
G = figure();
set(G,'position',[100,100,800,600]);
subplot(221),plot(n,real(st1),'k')
axis([0 N-1,-1.2 1.2])
title('(a)�ź�ʵ��(б�ӽ�Ϊ��)'),ylabel('����')
line([32,32],[-1.2,1.2],'Color','r','LineStyle','--')
subplot(222),plot(n,abs(Sf1),'k')
axis([0 N-1,0 10])
title('(b)�ź�Ƶ��(б�ӽ�Ϊ��)'),ylabel('����')
line([32,32],[0,6],'Color','r','LineStyle','--')
text(32,8,'$$f_{\eta_c}^{\prime}=0.00F_a$$','Interpreter','latex','FontSize',14,'Color','red','HorizontalAlignment','center')
subplot(223),plot(n,real(st2),'k')
axis([0 N-1,-1.2 1.2])
title('(c)�ź�ʵ��(б�ӽǷ���)'),xlabel('ʱ��(������)'),ylabel('����')
line([48,48],[-1.2 1.2],'Color','r','LineStyle','--')
subplot(224),plot(n,abs(Sf2),'k')
axis([0 N-1,0 10])
title('(d)�ź�Ƶ��(б�ӽǷ���)'),xlabel('Ƶ��(������)'),ylabel('����')
line([48,48],[0,6],'Color','r','LineStyle','--')
line([16,16],[0,10],'Color','r','LineStyle','--')
text(48,8,'$$f_{\eta_c}^{\prime}=0.25F_a$$','Interpreter','latex','FontSize',14,'Color','red','HorizontalAlignment','center')
sgtitle('ͼ5.5 б�ӽ�Ϊ��ͷ���ʱ�Ķ���������','Fontsize',20,'color','k')