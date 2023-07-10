%Calculate largest Lyapunov exponent from ODE directly.
%Algorithm is based on Alan Wolf, 1985.
% ％直接从ODE计算最大Lyapunov指数。
% ％算法基于Alan Wolf，1985。
%By Xiaowei Huai
%2015/5/28
%------------------------------------------------------------
close all;clear;clc;

%Spin-up to accquire post-transient initial condition
[~,yspin] = ode45(@lorenz63,1:0.01:50,[1,1,1]);
yinit = yspin(length(yspin),:);
orthmatrix = eye(3);
% orthmatrix = [1 0 0;
%               0 1 0;
%               0 0 1];
y = zeros(12,1);
y(1:3) = yinit;
y(4:12) = orthmatrix;

tstart = 0; % 时间初始值
%tstep = 1e-6; % 时间步长
%wholetimes = 1e6; % 总的循环次数
%steps = 1000; % 每次演化的步数
%iteratetimes = wholetimes/steps; % 演化的次数
iteratetimes = 500;
tincre = 1.0;
sum = zeros(3,1);

% 初始化三个Lyapunov指数
expo = zeros(iteratetimes,3);

for i=1:iteratetimes
    %tend = tstart + tstep*steps;
    %tspan = tstart:tstep:tend;   
    tend = tstart + tincre;
    [~,Y] = ode45(@lorenz_ode,[tstart,tend], y);

    % 取积分得到的最后一个时刻的值
    y = Y(size(Y,1),:);
    % 重新定义起始时刻
    tstart = tend;
    y0 = [y(4) y(7) y(10);
          y(5) y(8) y(11);
          y(6) y(9) y(12)];
    %正交化
    [y0,znorm] = GS(y0);
    sum = sum + log(znorm);
    y(4:12) = y0;

    %三个Lyapunov指数
    for j=1:3
        expo(i,j) = sum(j)/tstart;
    end
end

lyap = expo(length(expo),:);
disp(lyap)
%In this frame, Lyapunov exponents will be  0.9065   -0.0023  -14.5036.

%   作Lyapunov指数谱图
i = 1:iteratetimes;
plot(i,expo(:,1),'r-',i,expo(:,2),'g-',i,expo(:,3),'b-','LineWidth',1.5)
xlabel('\fontsize{14}Time');ylabel('\fontsize{14}Lyapunov Exponents')
legend('\lambda_1','\lambda_2','\lambda_3','Location','Best')
legend('boxoff')
print(gcf,'-dpng','LyapExpoSpectrum.png')