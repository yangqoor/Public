clc
clear
close all

% ��������
TBP = 724;             % ʱ������
T = 42e-6;             % �������ʱ��
Nfft = 2^11;           % FFT����
% ��������
B = TBP/T;             % �źŴ���
K = B/T;               % ���Ե�ƵƵ��
alpha_os = 1.07;       % ��������
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
% ������
window = kaiser(N,2.5)';          % ʱ��
Window = fftshift(window);        % Ƶ��
% �źű任
ht = st;                          % �����ź�
ht_window = window.*ht;           % �Ӵ�
Hf_2 = conj(fft(ht_window,Nfft));       % ���㲹����ɢ����Ҷ�任
% ��ͼ
H = figure;
set(H,'position',[500,500,600,400]);
subplot(211),plot(abs(Hf_2),'k')
axis([-50 2100,0 35])
title('(a)��Ȩ��Ƶ��ƥ���˲����ķ�����'),ylabel('����')
line([ 860, 860],[0,35],'Color','k','LineStyle','--')
line([1190,1190],[0,35],'Color','k','LineStyle','--')
line([990 ,990 ],[0,35],'Color','r','LineStyle','--')
line([1060,1060],[0,35],'Color','r','LineStyle','--')
subplot(212),plot(1:1:990,unwrap(-angle(Hf_2(1:1:990))),'k'),hold on
plot(1060:1:2048,unwrap(-angle(Hf_2(1060:1:2048))),'k')
axis([-50 2100,-2000 600])
title('(b)��Ȩ��Ƶ��ƥ���˲�������λ��'),xlabel('Ƶ��(FFT������)'),ylabel('����')
line([990 ,990 ],[-2000,600],'Color','r','LineStyle','--')
line([1060,1060],[-2000,600],'Color','r','LineStyle','--')
suptitle('ͼ3.11 ��ʽ�����ɵ�Ƶ��ƥ���˲���Ƶ����Ӧ�����ķ��Ⱥ���λ')