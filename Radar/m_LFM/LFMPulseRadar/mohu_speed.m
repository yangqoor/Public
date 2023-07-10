close all
clear all
clc
%下面例子对应，目标真实速度334m/s,脉冲一测得目标多部普通道号-3，脉冲二测得目标多普勒通道号4
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
title('解目标四速度模糊分析图');
xlabel('脉冲数M');
ylabel('真实多普勒值');
legend('f1函数','f2函数')




