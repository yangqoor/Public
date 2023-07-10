clc
clear
close all
% ��֪����
Ta = 128;                      % �������ʱ��
Ka = -0.085;                   % ��λ���Ƶ��
% ��������
Delta_f_dop = abs(Ka*Ta);      % ��λ�źŴ���
% ��������
alpha_as = [5,0.25];           % ��λ��������
Fa1 = alpha_as(1)*Delta_f_dop; % ��λ����Ƶ��PRF
N1 = 2*ceil(Fa1*Ta/2);         % ��λ��������
dt1 = Ta/N1;                   % ����ʱ����
df1 = Fa1/N1;                  % ����Ƶ�ʼ��
Fa2 = alpha_as(2)*Delta_f_dop; % ��λ����Ƶ��PRF
N2 = 2*ceil(Fa2*Ta/2) ;        % ��λ��������
dt2 = Ta/N2;                   % ����ʱ����
df2 = Fa2/N2;                  % ����Ƶ�ʼ��
% ��������
t1 = -Ta/2:dt1:Ta/2-dt1;       % ʱ�����
t2 = -Ta/2:dt2:Ta/2-dt2;       % ʱ�����
f1 = -Fa1/2:df1:Fa1/2-df1;     % Ƶ�ʱ���
f2 = -Fa2/2:df2:Fa2/2-df2;     % Ƶ�ʱ���
% �źű��
st1 = exp(1j*pi*Ka*t1.^2);     % ��λChirp�ź�
st2 = exp(1j*pi*Ka*t2.^2);     % ��λChirp�ź�
omega_a = sinc(6*t2/Ta).^2;    % ˫�����߲�������ͼ
st  = omega_a.*st2;            % ���߷���ͼ���Ƶķ�λChirp�ź�
omega_a_nor = abs(omega_a)./max(abs(omega_a));      % ��һ��
omega_a_log = 20*log10(omega_a_nor);                % ������
% ������
window_1 = kaiser(N2,2.5)';                         % ʱ��
Window_1 = fftshift(window_1);                      % Ƶ��
% �źű任-->��ʽһ
ht_1 = conj(fliplr(st));                            % ��ʱ�䷴�޺�ĸ�������ȡ������
ht_window_1 = window_1.*ht_1;                       % �Ӵ�
Hf_1 = fftshift(fft(ht_window_1,N2));               % ���㲹����ɢ����Ҷ�任
% ������
window_2 = kaiser(N2,2.5)';                         % ʱ��
Window_2 = fftshift(window_2);                      % Ƶ��
% �źű任-->��ʽ��
ht_2 = st;                                          % �����ź�
ht_window_2 = window_2.*ht_2;                       % �Ӵ�
Hf_2 = fftshift(conj(fft(ht_window_2,N2)));         % ���㲹����ɢ����Ҷ�任
% ������
window_3 = kaiser(N2,2.5)';                         % ʱ��
Window_3 = fftshift(window_3);                      % Ƶ��
% �źű任-->��ʽ��
Hf_3 = exp(1j*pi*f2.^2/Ka);                         % ���㲹����ɢ����Ҷ�任
% �źű��
Sf = fftshift(fft(st));
Sf_1 = Sf.*Hf_1;
st_1 = ifft(ifftshift(Sf_1));                       % ��ʽһƥ���˲����
st_1_nor = abs(st_1)./max(abs(st_1));               % ��һ��
st_1_log = 20*log10(st_1_nor);                      % ������
Sf_2 = Sf.*Hf_2;
st_2 = ifft(ifftshift(Sf_2));                       % ��ʽ��ƥ���˲����
st_2_nor = abs(st_2)./max(abs(st_2));               % ��һ��
st_2_log = 20*log10(st_2_nor);                      % ������
Sf_3 = Sf.*Hf_3;
st_3 = ifft(ifftshift(Sf_3));                       % ��ʽ��ƥ���˲����
st_3_nor = abs(st_3)./max(abs(st_3));               % ��һ��
st_3_log = 20*log10(st_3_nor);                      % ������
% ��ͼ
H = figure();
set(H,'position',[100,100,800,600]);
subplot(311),plot(t2,real(st2),'k')
axis([-Ta/2-5 Ta/2+5,-1.2 1.2])
title('(a)�����λChirp�ź�ʵ�����������߲�������ͼ'),ylabel('����')
subplot(312),plot(t2,omega_a_log,'k')
axis([-Ta/2-5 Ta/2+5,-60 0])
title('(b)���߲�������ͼ'),ylabel('����(dB)')
line([-16,-16],[-40,0],'Color','r','LineStyle','--')
line([+16,+16],[-40,0],'Color','r','LineStyle','--')
arrow([-16,-20],[+16,-20],'Color','k','Linewidth',1);
arrow([+16,-20],[-16,-20],'Color','k','Linewidth',1);
arrow([-69,-20],[-16,-20],'Color','k','Linewidth',1);
arrow([-16,-20],[-69,-20],'Color','k','Linewidth',1);
arrow([+16,-20],[+69,-20],'Color','k','Linewidth',1);
arrow([+69,-20],[+16,-20],'Color','k','Linewidth',1);
text(0,-32,'PRFʱ��','FontSize',14,'Color','red','HorizontalAlignment','center')
text(-40,-12,'�ص�����','FontSize',14,'Color','red','HorizontalAlignment','center')
text(+40,-12,'�ص�����','FontSize',14,'Color','red','HorizontalAlignment','center')
subplot(313),plot(t2,fftshift(st_1_log),'k')
axis([-Ta/2-5 Ta/2+5,-50 0])
title('(a)ѹ�����Ŀ������Ӱ(��Ӱ)'),xlabel('��λʱ��'),ylabel('����(dB)')
sgtitle('ͼ5.4 �ɷ�λChrip�źŻ����ɵķ�λģ��','Fontsize',20,'color','k')