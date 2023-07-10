clc
clear
close all

% ��������
TBP = 100;             % ʱ������
T = 7.2e-6;            % �������ʱ��
t_0 = 1e-6;            % ����ز�ʱ��
% ��������
B = TBP/T;             % �źŴ���
K = B/T;               % ���Ե�ƵƵ��
alpha_os = 1.25;       % �������ʣ�ʹ�ýϸߵĹ���������Ϊ����߲���Ƶ��
F = alpha_os*B;        % ����Ƶ��
N = 2*ceil(F*T/2);     % ��������
dt = T/N;              % ����ʱ����
df = F/N;              % ����Ƶ�ʼ��
% ��������
t = -T/2+t_0:dt:T/2+t_0-dt;             % ʱ�����
f = -F/2:df:F/2-df;                     % Ƶ�ʱ���
% �źű��
st = exp(1j*pi*K*t.^2);                 % Chirp�źŸ������ʽ
srt = exp(1j*pi*K*(t-t_0).^2);          % Chirp�ź�ʱ�ӱ��ʽ
Srf = fft(srt);                         % Chirp�ź�Ƶ�ױ��ʽ
Hf = exp(1j*pi*f.^2/K);                 % Ƶ��ƥ���˲���
Soutf = Srf.*Hf;                        % ƥ���˲������
% ��ͼ
H = figure;
set(H,'position',[500,500,600,150]);
subplot(121),plot(f*1e-6,real(Soutf))
axis([-10 10,-15 15])
title('Ƶ��ʵ��'),xlabel('Ƶ��(MHz)'),ylabel('����')
subplot(122),plot(f*1e-6,imag(Soutf))
axis([-10 10,-15 15])
title('Ƶ���鲿'),xlabel('Ƶ��(MHz)'),ylabel('����')
% suptitle('ͼ3.9 ƥ���˲�����ź�Ƶ��')