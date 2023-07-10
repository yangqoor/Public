clc
clear
close all

% ��������
B = 5.80e+6;           % �źŴ���
T = 7.26e-6;           % �������ʱ��
% ��������
K = B/T;               % ���Ե�ƵƵ��
alpha = 5;             % ��������
F = alpha*B;           % ����Ƶ��
N = F*T;               % ��������
dt = T/N;              % ����ʱ����
% ��������
t = -T/2:dt:T/2-dt;    % ʱ�����

% % �����Ա����ļ��ַ�ʽ
% t1 = linspace(-T/2,T/2-T/N,N)
% t2 = -T/2:dt:T/2-dt
% t3 = (-N/2:N/2-1)/N*T

% �źű��
st = exp(1j*pi*K*t.^2);    % Chirp�źŸ������ʽ
% ��������
f = K*t;                   % ˲ʱƵ��
phi = pi*K*t.^2;           % ˲ʱ��λ
% ��ͼ
figure
subplot(221),plot(t*1e+6,real(st))
title('(a)�ź�ʵ��'),xlabel('�����t_0ʱ��(\mus)'),ylabel('����')
axis([-4 4,-1.2 1.2])
subplot(222),plot(t*1e+6,phi)
title('(b)�ź���λ'),xlabel('�����t_0ʱ��(\mus)'),ylabel('��λ(����)')
axis([-4 4,-5 40])
subplot(223),plot(t*1e+6,imag(st))
title('(c)�ź��鲿'),xlabel('�����t_0ʱ��(\mus)'),ylabel('����')
axis([-4 4,-1.2 1.2])
subplot(224),plot(t*1e+6,f*1e-6)
title('(da)�ź�Ƶ��'),xlabel('�����t_0ʱ��(\mus)'),ylabel('MHz')
axis([-4 4,-3.2 3.2])
suptitle('ͼ3.1 ���Ե�Ƶ�������λ��Ƶ��')