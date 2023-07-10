clc
clear
close all

% ��������
TBP = 100;             % ʱ������
T = 10e-6;             % �������ʱ��
% ��������
B = TBP/T;             % �źŴ���
K = B/T;               % ���Ե�ƵƵ��
alpha_os = 50;         % �������ʣ�ʹ�ýϸߵĹ���������Ϊ����߲���Ƶ��
F = alpha_os*B;        % ����Ƶ��
N = 2*ceil(F*T/2);     % ��������
dt = T/N;              % ����ʱ����
df = F/N;              % ����Ƶ�ʼ��
% ��������
t = -T/2:dt:T/2-dt;    % ʱ�����
f = -F/2:df:F/2-df;    % Ƶ�ʱ���
t_out = linspace(2*t(1),2*t(end),2*length(t)-1);    % ѭ���������źų���    
% �źű��
st = exp(1j*pi*K*t.^2);               % Chirp�źŸ������ʽ
ht = conj(fliplr(st));                % ʱ��ƥ���˲���
sout = conv(st,ht);                   % ƥ���˲������
sout = sout/max(sout);                % ��һ��
% ��ͼ
figure
plot(t_out*1e+6,real(sout))
axis([-1 1,-0.4 1.2])
xlabel('ʱ��(\mus)'),ylabel('����')
line([-1,1],[ 0,  0],'Color','k')
line([ 0,0],[-0.4,1.2],'Color','k')
line([-1,-0.05],[0.707,0.707],'Color','k','LineStyle','--')
line([ 0.05, 1],[0.707,0.707],'Color','k','LineStyle','--')
arrow([-0.3,0.707],[-0.05,0.707]);
arrow([ 0.3,0.707],[ 0.05,0.707]);
suptitle('ͼ3.5 ƥ���˲��������3dB�ֱ��ʵĲ���')