close all
clear all
clc
%�������Ӷ�Ӧ��Ŀ����ʵ�ٶ�334m/s,����һ���Ŀ��ಿ��ͨ����-3����������Ŀ�������ͨ����4
M=-8:1:7;
PRT1 = 240e-6;
PRT2 = PRT1*1.5;
PRF1 = 1/PRT1;
PRF2 = 1/PRT2;
fd1 = PRF1/16*(-3);
fd2 = PRF2/16*(4);
f1=PRF1*M+fd1;
f2=PRF2*M+fd2;
figure(1); 
plot(M,f1,'-r',M,f2),grid on;
title('��Ŀ�����ٶ�ģ������ͼ');
xlabel('������M');
ylabel('��ʵ������ֵ');
legend('f1����','f2����')




