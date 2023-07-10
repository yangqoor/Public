%  均匀线阵，平顶方向图综合
%主瓣响应与期望波束最小均方误差，副瓣小于某一电平值，论文中的仿真，
%min abs（p(thetam)-pd(theta)）
%p(thetas)<=sigma
clc;
clear all;
close all;

%=================参数设置=====================%
ima=sqrt(-1);
C_num=41;                            % 阵元数
f=10e9;                             %频率12GHz
lamda = 3e8/f;                        % 波长
d = 0.5*lamda;                      % 阵元间距
theta0=0;                           % 目标
main_width=10;                       % 单位/度

deta=5;                              %过渡带宽
main_lobe_l=theta0-main_width/2;     %主瓣角度下限
main_lobe_u=theta0+main_width/2;     %主瓣角度上限
side_lobe_l=main_lobe_l-deta;        %旁瓣角度下限
side_lobe_u=main_lobe_u+deta;        %旁瓣角度上限


theta=[-90:90]';            %角度均匀划分

A=exp( -ima*2*pi*d*sin(theta*pi/180)*[-(C_num-1)/2:(C_num-1)/2]/lamda );

ind=find(main_lobe_l<=theta & theta<=main_lobe_u);
L=length(ind);
Am = A(ind,:);                       %对应主瓣区

ind=find(-90<=theta & theta<=side_lobe_l | side_lobe_u<=theta & theta<=90);
As = A( ind,:);                      %对应旁瓣区
%===========================优化形式==========================%
cvx_begin

  variable w(C_num) complex  
  minimize( ( Am*w-1 )'*( Am*w-1 )/L )    %主瓣
  
  subject to    
    abs( As*w )<=10^(-30/20);
    
cvx_end

% check if problem was successfully solved
if ~strfind(cvx_status,'Solved')
    return
end
      
%====================方向图形成====================%
theta=[-90:0.5:90];
a0=exp(ima*2*pi*d*sin(theta0*pi/180)*[-(C_num-1)/2:(C_num-1)/2]'/lamda);
w0=a0/norm(a0)/norm(a0);
w1=w/norm(w)/norm(a0);                %方向图综合的最优权
% w1=w;                %方向图综合的最优权
% w0=a0/norm(a0);
% w1=w/norm(w);  
for j=1:length(theta)
    a=exp(ima*2*pi*d*sin(theta(j)*pi/180)*[-(C_num-1)/2:(C_num-1)/2]'/lamda);
    gain(j)=w0'*a;               %普通静态方向图响应
    gain_opt(j)=w1'*a;             %综合方向图响应
end
max_value=1;

G=abs(gain)/max_value;
G=20*log10(G);                    %普通方向图

Y=abs(gain_opt)/max_value;        %优化方向图
Y=20*log10(Y);

figure(1);clf
ymin = -100; ymax = 5;
plot(theta,Y,'.-b',theta,G,'p-m',...
     [theta0 theta0],[ymin ymax],'k--');
   
grid on,hold on
xlabel('俯仰角/度'), ylabel('幅度/dB');
axis([-90 90 ymin ymax]);
legend('优化的','普通的');
