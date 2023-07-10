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
st1 = exp(1j*pi*Ka*t1.^2);     % Chirp�źŸ������ʽ
st2 = exp(1j*pi*Ka*t2.^2);     % Chirp�źŸ������ʽ
% ��������
F1 = Ka*t1/Fa2;
F2 = (Ka*t2+floor((Fa2/2-Ka*t2)/Fa2)*Fa2)/Fa2;
% ��ͼ
H = figure();
set(H,'position',[100,100,800,600]);
subplot(311),plot(t1,real(st1),'k')
axis([-Ta/2-5 Ta/2+5,-1.2 1.2])
title('(a)���ǰ��λChirp�ź�ʵ��'),ylabel('����')
subplot(312),plot(t2,real(st2),'k')
axis([-Ta/2-5 Ta/2+5,-1.2 1.2])
title('(b)�����λChirp�ź�ʵ��'),ylabel('����')
subplot(313),plot(t1,F1,'K--',t2,F2,'K')
axis([-Ta/2-5 Ta/2+5,-2.2 2.2])
title('(c)�ź�˲ʱƵ��'),xlabel('��λʱ��'),ylabel('Ƶ��(PRF)')
arrow([-16,1],[+16,1],'Color','k','Linewidth',1);
arrow([+16,1],[-16,1],'Color','k','Linewidth',1);
text(0,+1.5,'PRFʱ��','FontSize',14,'Color','red','HorizontalAlignment','center')
line([-16,-16],[-2,+2],'Color','r','LineStyle','--')
line([+16,+16],[-2,+2],'Color','r','LineStyle','--')
text(0,-1.5,'δ���Ƶ��','FontSize',14,'Color','r','HorizontalAlignment','center')
text(-40,-1.5,'���Ƶ��','FontSize',14,'Color','r','HorizontalAlignment','center')
text(+40,-1.5,'���Ƶ��','FontSize',14,'Color','r','HorizontalAlignment','center')
sgtitle('ͼ5.3 ��ɢ����Է�λ�źŵĲ�����ɵķ�λ���','Fontsize',20,'color','k')