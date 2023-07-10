% 右天线增益函数
function R=gain_r(fw0,fw)   % fw0是等信号轴指向，fw是目标角度
%雷达波束宽度
width_r=5;
% 天线最大值偏离等信号轴夹角
c_max=1; 
% 程序
d=2*pi/width_r;
g=fw0+c_max;
p=fw-g;  
R=abs(sinc(d*p/pi));