clc
clear
close all

% ��������
TBP = 720;             % ʱ������
T = 10e-6;             % �������ʱ��
% ��������
B = TBP/T;             % �źŴ���
K = B/T;               % ���Ե�ƵƵ��
alpha = 1.25;          % ��������
F = alpha*B;           % ����Ƶ��
N = 2*ceil(F*T/2);     % ��������
dt = T/N;              % ����ʱ����
df = F/N;              % ����Ƶ�ʼ��
% ��������
t = -T/2:dt:T/2-dt;    % ʱ�����
f = -F/2:df:F/2-df;    % Ƶ�ʱ���
% �źű��
st = exp(1j*pi*K*t.^2);               % Chirp�źŸ������ʽ
Sf1 = exp(-1j*pi*f.^2/K);             % Chirp�ź�Ƶ�ױ��ʽ
Sf2 = fftshift(fft(fftshift(st)));    % Chirp�ź�Ƶ�ױ��ʽ
% ��ͼ
% figure
% subplot(221),plot(f*1e-6,real(Sf1))
% axis([-10 10,-1.2 1.2])
% title('(a)Ƶ��ʵ��'),xlabel('��һ����Ƶ��(Hz)'),ylabel('����')
% subplot(222),plot(f*1e-6,abs(Sf1))
% axis([-10 10,-1.2 1.2])
% title('(b)Ƶ����λ'),xlabel('��һ����Ƶ��(Hz)'),ylabel('����')
% subplot(223),plot(f*1e-6,imag(Sf1))
% axis([-10 10,-1.2 1.2])
% title('(c)Ƶ���鲿'),xlabel('��һ����Ƶ��(Hz)'),ylabel('����')
% subplot(224),plot(f*1e-6,unwrap(angle(Sf1)))
% axis([-28 28,0 400])
% title('(d)Ƶ����λ'),xlabel('��һ����Ƶ��(Hz)'),ylabel('��λ(����)')
% suptitle('ͼ3.2 ���Ե�Ƶ����ĸ�Ƶ��')

figure
subplot(221),plot(f*1e-6,real(Sf2))
axis([-10 10,-40 40])
title('(a)Ƶ��ʵ��'),xlabel('��һ����Ƶ��(Hz)'),ylabel('����')
subplot(222),plot(f*1e-6,abs(Sf2))
axis([-50 50,0 40])
title('(b)Ƶ����λ'),xlabel('��һ����Ƶ��(Hz)'),ylabel('����')
subplot(223),plot(f*1e-6,imag(Sf2))
axis([-10 10,-40 40])
title('(c)Ƶ���鲿'),xlabel('��һ����Ƶ��(Hz)'),ylabel('����')
subplot(224),plot(f*1e-6,unwrap(angle(Sf2)))
axis([-50 50,0 900])
title('(d)Ƶ����λ'),xlabel('��һ����Ƶ��(Hz)'),ylabel('��λ(����)')
suptitle('ͼ3.2 ���Ե�Ƶ����ĸ�Ƶ��')