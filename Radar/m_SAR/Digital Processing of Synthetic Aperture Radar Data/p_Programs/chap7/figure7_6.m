clc, clear, close all;
%% �������� 
N = 512;                                                    % �ܵĲ�������
Fr = 150;                                                   % �źŲ���Ƶ��
Nr = 100;                                                   % �źŲ�������
Kr = 100;                                                   % �źŵĵ�Ƶ��
%% ��������
T = N/Fr;                                                   % �ܵĳ���ʱ��
Tr = Nr/Fr;                                                 % �źų���ʱ��
alpha = 0.05;                                               % ƫ�Ʋ���
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% alpha = tau_a/tau_b - 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ��������
t_0 = -T/2 : T/N : T/2-T/N;
t_1 = -Tr/2 : Tr/Nr : Tr/2-Tr/Nr;
f = -Fr/2 : Fr/N : Fr/2-Fr/N;
%% �ź�����
%  ԭʼ�ź�
s_0_t = zeros(1, N);
s_0_t(6:105) = exp(1j*pi*Kr*t_1.^2);
s_0_t(206:305) = exp(1j*pi*Kr*t_1.^2);
s_0_t(406:505) = exp(1j*pi*Kr*t_1.^2);
%  ����ź�
s_p_t = exp(1j*pi*alpha*Kr*t_0.^2);
%% �źŴ���
s_1_t = s_0_t .* s_p_t;
%% ƥ���˲�
H_f = exp(1j*pi*f.^2/Kr);
s_2_t = ifft(fftshift(fft(s_0_t, [], 2)) .* H_f, [], 2);
s_3_t = ifft(fftshift(fft(s_1_t, [], 2)) .* H_f, [], 2);
%% ����ͼ��
H3 = figure();
set(H3,'position',[100,100,600,900]); 
subplot(511), plot(real(s_0_t)), axis([0 512, -1.2 1.2]), ylabel('����'), title('(a)ԭʼ�ź�ʵ��');
subplot(512), plot(real(s_p_t)), axis([0 512, -1.2 1.2]), ylabel('����'), title('(b)��귽��ʵ��');
subplot(513), plot(real(s_1_t)), axis([0 512, -1.2 1.2]), ylabel('����'), title('(c)������ź�ʵ��');
subplot(514), plot(abs(s_2_t)), hold on, plot(abs(s_3_t)), hold off, axis([0 512, 0 12]), legend('ԭʼ�ź�', '������ź�'), ylabel('����'), title('(d)ѹ�����ԭʼ�źźͱ���ź�');
subplot(515), plot(abs(s_2_t)), hold on, plot(abs(s_3_t)), hold off, axis([428 480, 0 12]), legend('ԭʼ�ź�', '������ź�'), xlabel('ʱ�䣨�����㣩'), ylabel('����'), title('(e)(d)���ұ�Ŀ��Ŵ�����ʽ');
