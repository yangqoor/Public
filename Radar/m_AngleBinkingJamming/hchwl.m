%和差网络
function [G_h,G_fwch]=hchwl(fw0,fw)   % fw0是等信号轴指向，fw是目标角度
% 程序
%和波束方向图增益计算
G_h=abs(gain_l(fw0,fw)+gain_r(fw0,fw));
%差波束方向图增益计算 
G_fwch=abs(gain_r(fw0,fw)-gain_l(fw0,fw));
