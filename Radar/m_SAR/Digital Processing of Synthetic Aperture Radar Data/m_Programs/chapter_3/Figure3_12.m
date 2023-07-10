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
Hf_3 = Window.*exp(1j*pi*f.^2/K); % ���㲹����ɢ����Ҷ�任
HF_phi = pi*f.^2/K;               % Ƶ��ƥ���˲�������λ
HF_fre = -F/2:df:F/2-df;          % Ƶ��ƥ���˲�����Ƶ��
% ��ͼ
H = figure;
set(H,'position',[300,300,600,600]);
subplot(311),plot(abs(Hf_3),'k')
axis([-15 791,0 1.2])
title('(a)��Ȩ��Ƶ��ƥ���˲����ķ���'),ylabel('����')
line([362,362],[0,1.2],'Color','k','LineStyle','--')
line([414,414],[0,1.2],'Color','k','LineStyle','--')
arrow([130,0.3],[0  ,0.3],'Color','k','Linewidth',1);
arrow([232,0.3],[362,0.3],'Color','k','Linewidth',1);
text(181,0.3,'B/2','Color','red','HorizontalAlignment','center')
arrow([544,0.3],[414,0.3],'Color','k','Linewidth',1);
arrow([646,0.3],[776,0.3],'Color','k','Linewidth',1);
text(595,0.3,'B/2','Color','red','HorizontalAlignment','center')
line([388,388],[0,1.2],'Color','r','LineStyle','--')
subplot(312),plot(1:1:388,HF_fre(388:1:775)*1e-6,'k'),hold on
plot(388:1:775,HF_fre(1:1:388)*1e-6,'k')
title('(b)��Ȩ��Ƶ��ƥ���˲�����Ƶ��'),ylabel('Ƶ��(MHz)')
axis([-15 791,-10 10])
line([388,388],[-10 10],'Color','r','LineStyle','--')
subplot(313),plot(fftshift(HF_phi),'k')
title('(c)��Ȩ��Ƶ��ƥ���˲�������λ'),xlabel('Ƶ��(������)'),ylabel('����')
axis([-15 791,-50 700])
line([388,388],[-500,700],'Color','r','LineStyle','--')
suptitle('ͼ3.12 ��ʽ�����ɵ�ƥ���˲���')