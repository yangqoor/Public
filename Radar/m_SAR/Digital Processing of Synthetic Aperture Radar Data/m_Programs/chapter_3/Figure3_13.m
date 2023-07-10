clc
clear
close all

% ��������
TBP = 80;              % ʱ������
T = 10e-6;             % �������ʱ��
% ��������
B = TBP/T;             % �źŴ���
K = B/T;               % ���Ե�ƵƵ��
alpha_os = 5;          % ��������
F = alpha_os*B;        % ����Ƶ��
N = 2*ceil(F*T/2);     % ��������
dt = T/N;              % ����ʱ����
% ��������
t = -T/2:dt:T/2-dt;    % ʱ�����
% ��������
N_ZD = 60;             % ��Ƶ��λ��Ŀ���е��Ҳ�N_DZ=(N_L-N_R)/2������
t_c = N_ZD*dt;         % �������������t=0��ʱ��ƫ��
% �źű��
st1 = exp(1j*pi*K*(t-t_c).^2);                       % �趨���ȵ����Ե�Ƶ�ź�
st2 = zeros(1,N);                                    % �趨���źŵȳ��Ŀ��ź�
st  = [zeros(1,40),st1,st2,st1,st2,st1,zeros(1,40)]; % ʵ���ź�
N_st = length(st);                                   % ʵ���źŵĳ���
% ��������
n = 0:1:N_st-1;                        % ������
f = -F/2:F/N_st:F/2-F/N_st;            % Ƶ����      
% ������
window_1 = kaiser(N,2.5)';             % ʱ��
Window_1 = fftshift(window_1);         % Ƶ��
% �źű任-->��ʽһ
ht_1 = conj(fliplr(st1));              % ��ʱ�䷴�޺�ĸ�������ȡ������
ht_window_1 = window_1.*ht_1;          % �Ӵ�
Hf_1 = fftshift(fft(ht_1,N_st));       % ���㲹����ɢ����Ҷ�任
% ������
window_2 = kaiser(N,2.5)';             % ʱ��
Window_2 = fftshift(window_2);         % Ƶ��
% �źű任-->��ʽ��
ht_2 = st1;                            % �����ź�
ht_window_2 = window_2.*ht_2;          % �Ӵ�
Hf_2 = fftshift(conj(fft(ht_2,N_st))); % ���㲹����ɢ����Ҷ�任
% ������
window_3 = kaiser(N_st,2.5)';          % ʱ��
Window_3 = fftshift(window_3);         % Ƶ��
% �źű任-->��ʽ��
Hf_3 = Window_3.*exp(1j*pi*f.^2/K);    % ���㲹����ɢ����Ҷ�任
% �źű��
Sf = fftshift(fft(st));
Soutf_1 = Sf.*Hf_1;
soutt_1 = ifft(ifftshift(Soutf_1));    % ��ʽһƥ���˲����
Soutf_2 = Sf.*Hf_2;
soutt_2 = ifft(ifftshift(Soutf_2));    % ��ʽ��ƥ���˲����
Soutf_3 = Sf.*Hf_3;
soutt_3 = ifft(ifftshift(Soutf_3));    % ��ʽ��ƥ���˲����
% ��ͼ
H = figure;
set(H,'position',[100,100,600,800]);
subplot(411),plot(n,real(st),'k')
axis([0 N_st,-1.2 2])
title('(a)���������źŵ�ʵ��'),xlabel('ʱ��(������)'),ylabel('����')
text( 470,0.5,'A','Color','black','HorizontalAlignment','center')
text(1270,0.5,'B','Color','black','HorizontalAlignment','center')
text(2070,0.5,'C','Color','black','HorizontalAlignment','center')
line([ 40, 40],[-1.2,2],'Color','r','LineStyle','--')
line([440,440],[-1.2,2],'Color','r','LineStyle','--')
line([300,300],[-1.2,1.3],'Color','r','LineStyle','--')
arrow([310,1.2],[ 40,1.2],'Color','k','Linewidth',1);
arrow([310,1.2],[440,1.2],'Color','k','Linewidth',1);
text(220,1.7,'N','Color','red','HorizontalAlignment','center')
line([ 840, 840],[-1.2,2],'Color','r','LineStyle','--')
line([1240,1240],[-1.2,2],'Color','r','LineStyle','--')
line([1100,1100],[-1.2,1.3],'Color','r','LineStyle','--')
arrow([ 950,1.2],[ 840,1.2],'Color','k','Linewidth',1);
arrow([ 950,1.2],[1100,1.2],'Color','k','Linewidth',1);
arrow([1210,1.2],[1100,1.2],'Color','k','Linewidth',1);
arrow([1210,1.2],[1240,1.2],'Color','k','Linewidth',1);
text( 970,1.7,'N_L','Color','red','HorizontalAlignment','center')
text(1170,1.7,'N_R','Color','red','HorizontalAlignment','center')
line([1640,1640],[-1.2,2],'Color','r','LineStyle','--')
line([2040,2040],[-1.2,2],'Color','r','LineStyle','--')
line([1900,1900],[-1.2,1.3],'Color','r','LineStyle','--')
text(1900,1.7,'N_{ZD}','Color','red','HorizontalAlignment','center')
subplot(412),plot(n,abs(soutt_1),'k')
axis([0 N_st,0 500])
title('(b)��ʽһ��ƥ���˲��������'),xlabel('ʱ��(������)'),ylabel('����')
text( 470,300,'A','Color','black','HorizontalAlignment','center')
text(1270,300,'B','Color','black','HorizontalAlignment','center')
text(2070,300,'C','Color','black','HorizontalAlignment','center')
line([ 440, 440],[0,500],'Color','r','LineStyle','--')
line([1240,1240],[0,500],'Color','r','LineStyle','--')
line([2040,2040],[0,500],'Color','r','LineStyle','--')
line([ 400, 400],[0,150],'Color','b','LineStyle','--')
arrow([ 200,150],[  0,150],'Color','k','Linewidth',1);
arrow([ 200,150],[400,150],'Color','k','Linewidth',1);
text( 200,200,'TA','Color','red','HorizontalAlignment','center')
subplot(413),plot(n,abs(soutt_2),'k')
axis([0 N_st,0 500])
title('(c)��ʽ����ƥ���˲��������'),xlabel('ʱ��(������)'),ylabel('����')
text(  70,300,'A','Color','black','HorizontalAlignment','center')
text( 870,300,'B','Color','black','HorizontalAlignment','center')
text(1670,300,'C','Color','black','HorizontalAlignment','center')
line([  40,  40],[0,500],'Color','r','LineStyle','--')
line([ 840, 840],[0,500],'Color','r','LineStyle','--')
line([1640,1640],[0,500],'Color','r','LineStyle','--')
line([1680,1680],[0,150],'Color','b','LineStyle','--')
arrow([1840,150],[2080,150],'Color','k','Linewidth',1);
arrow([1840,150],[1680,150],'Color','k','Linewidth',1);
text(1880,200,'TA','Color','red','HorizontalAlignment','center')
subplot(414),plot(n,abs(soutt_3),'k')
axis([0 N_st,0   6])
title('(d)��ʽ����ƥ���˲��������'),xlabel('ʱ��(������)'),ylabel('����')
text( 330,3,'A','Color','black','HorizontalAlignment','center')
text(1130,3,'B','Color','black','HorizontalAlignment','center')
text(1930,3,'C','Color','black','HorizontalAlignment','center')
line([ 300, 300],[0,6],'Color','r','LineStyle','--')
line([1100,1100],[0,6],'Color','r','LineStyle','--')
line([1900,1900],[0,6],'Color','r','LineStyle','--')
line([ 260, 260],[   0,1.5],'Color','b','LineStyle','--')
arrow([ 150,1.5],[   0,1.5],'Color','k','Linewidth',1);
arrow([ 150,1.5],[ 260,1.5],'Color','k','Linewidth',1);
text( 150,2.3,'TA_L','Color','red','HorizontalAlignment','center')
line([1940,1940],[   0,1.5],'Color','b','LineStyle','--')
arrow([2000,1.5],[2080,1.5],'Color','k','Linewidth',1);
arrow([2000,1.5],[1940,1.5],'Color','k','Linewidth',1);
text(2000,2.3,'TA_R','Color','red','HorizontalAlignment','center')
suptitle('ͼ3.13 ͨ��ѹ��Ŀ���λ����˵�������źŵ���������TAֵ')