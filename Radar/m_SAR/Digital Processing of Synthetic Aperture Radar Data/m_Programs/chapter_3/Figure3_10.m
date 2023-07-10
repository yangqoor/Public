clc
clear
close all

% ��������
TBP = 100;             % ʱ������
T = 7.2e-6;            % �������ʱ��
% ��������
B = TBP/T;             % �źŴ���
K = B/T;               % ���Ե�ƵƵ��
alpha_os = 1.25;       % �������ʣ�ʹ�ýϸߵĹ���������Ϊ����߲���Ƶ��
F = alpha_os*B;        % ����Ƶ��
N = 2*ceil(F*T/2);     % ��������
dt = T/N;              % ����ʱ����
df = F/N;              % ����Ƶ�ʼ��
% ��������
t = -T/2:dt:T/2-dt;    % ʱ�����
f = -F/2:df:F/2-df;    % Ƶ�ʱ���
% �źű��
st = exp(1j*pi*K*t.^2);           % Chirp�źŸ������ʽ
Sf = fft((st));                   % Chirp�ź�Ƶ�ױ��ʽ
Hf = exp(1j*pi*f.^2/K);           % Ƶ��ƥ���˲���
Soutf = Sf.*Hf;                   % ƥ���˲������
% ������
window = kaiser(N,2.5)';          % ʱ��
Window = fftshift(window);        % Ƶ��
% �źű任
st_window = window.*exp(1j*pi*K*t.^2);          % �Ӵ����Chirp�ź�
Hf_Window = Window.*Hf;                         % �Ӵ����Ƶ��Ƶ���˲���
Soutf_Window = Hf_Window.*Sf;                   % �Ӵ����ƥ���˲������
% ��ͼ
H = figure;
set(H,'position',[500,500,600,300]);
subplot(221),plot(t*1e+6,window)
axis([-4 4,0 1.2])
title('ʱ�򴰺���'),ylabel('����')
subplot(222),plot(f*1e-6,Window)
axis([-10 10,0 1.2])
title('Ƶ�򴰺���')
subplot(223),plot(t*1e+6,real(st_window))
axis([-4 4,-1.2 1.2])
title('�Ӵ�����ź�ʵ��'),xlabel('ʱ��(\mus)'),ylabel('����')
subplot(224),plot(f*1e-6,real(Soutf_Window))
axis([-10 10,-15 15])
title('�Ӵ����Ƶ��ʵ��'),xlabel('Ƶ��(MHz)')
suptitle('ͼ3.10 Kaiser����ʱ���Ƶ���е�ʵ����ʽ')