%论文《基于凸优化及其求解软件的最低旁瓣方向图综合》
%的仿真,旁瓣峰值最小,没有设置零点
clc;
clear all;
close all;
%================参数设置===============%
ima=sqrt(-1);
f=5.4e9;
lamda=3e8/f;
d=0.5*lamda;
C_num=10;  %%阵元数
theta0=60; %%目标
beamwidth=40; %%主瓣宽
theta=[0:180];

side_l=theta0-beamwidth/2;
side_u=theta0+beamwidth/2;
ind=find(0<=theta&theta<=side_l | side_u<=theta&theta<=180);

A=exp(-ima*2*pi*d*cosd(theta')*[0:C_num-1]/lamda);
Am=A(find(theta==theta0),:);%主瓣区的导向矢量
As=A(ind,:);         %旁瓣区的导向矢量


%===============优化方式================%
cvx_begin 
   variable w(C_num) complex
   minimize(max(abs(As*w)))   
   subject to
     Am*w==1;
          
cvx_end


%================方向图形成===============%
% w1=w/max(abs(w));
for n=1:length(theta)
    a=exp(ima*2*pi*d*cos(theta(n)*pi/180)*[0:C_num-1]'/lamda);
    gain(n)=w'*a;
end
G=abs(gain)/max(abs(gain));
G=20*log10(G);
G=max(G,-40);

%  画图
figure(1);
plot(theta,G);
grid on,hold on


xlabel('方位角/°');
ylabel('幅度/dB');
title('均匀线阵综合方向图')

   
   