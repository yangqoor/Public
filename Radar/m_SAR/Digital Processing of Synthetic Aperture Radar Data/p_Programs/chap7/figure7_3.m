clc, clear, close all;
%% ��������
T = 1;                                                      % �ܵĳ���ʱ��
Fr = 800;                                                   % �źŲ���Ƶ��
Nr = 700;                                                   % �źŲ�������
Kr = 100;                                                   % �źŵĵ�Ƶ��
Bw = 87.5;                                                  % �źŴ���
%% ��������
N = Fr*T;                                                   % �ܵĲ�������
Tr = Nr/Fr;                                                 % �źų���ʱ��
Delta_tau = 50/Fr;                                          % ƫ�Ʋ���
%% ��������
t_0 = -Tr/2 : Tr/Nr : Tr/2-Tr/Nr;    
t_p = -T/2 : T/N : T/2-T/N;
f = -Fr/2 : Fr/N : Fr/2-Fr/N;
%% �ź�����
s_0_t = zeros(1, N);
s_0_t(50:749) = exp(1j*pi*Kr*t_0.^2);                       % ԭʼ�ź�
s_p_t = exp(1j*2*pi*Kr*t_p*Delta_tau);                      % ��귽��
%% �źŴ���
s_1_t = s_0_t .* s_p_t;                                     % ������ź�
%% ƥ���˲�
H_f = exp(1j*pi*f.^2/Kr);               
s_2_t = ifft(fftshift(fft(s_0_t, [], 2)) .* H_f, [], 2);
s_3_t = ifft(fftshift(fft(s_1_t, [], 2)) .* H_f, [], 2);
%% ����ͼ��
H1 = figure();
set(H1,'position',[100,100,600,600]);  
subplot(411), plot(real(s_0_t)), ylabel('����'), title('(a)ԭʼ�ź�ʵ��');
subplot(412), plot(real(s_p_t)), ylabel('����'), title('(b)��귽��ʵ��');
subplot(413), plot(real(s_1_t)), ylabel('����'), title('(c)������ź�ʵ��');
subplot(414), plot(abs(s_2_t), '--'), hold on, plot(abs(s_3_t)), hold off, legend('ԭʼ�ź�', '������ź�'), xlabel('ʱ�䣨�����㣩'), ylabel('����'), title('(d)ѹ�����ԭʼ�źźͱ���ź�');
sgtitle('Figure7.3 ��꼰ѹ��֮��ĵ�Ŀ��ƽ��');