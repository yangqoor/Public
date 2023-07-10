%Absolute error of Lyapunov exponents with respect to changes of iteration times.

%By Xiaowei Huai
%2015/6/16
%------------------------------------------------------------
close all;clear;clc;
kx = linspace(1000,10000,10);

%Spin-up to accquire post-transient initial condition
[~,yspin] = ode45(@lorenz63,1:0.01:50,[1,1,1]);
yinit = yspin(length(yspin),:);
orthmatrix = eye(3);
lyap=zeros(10,3);

for k=1:10    
    y = zeros(12,1);
    y(1:3) = yinit;
    y(4:12) = orthmatrix;

    tstart = 0; % 时间初始值
    st = 0.05;
    sum = zeros(3,1);
    iteratetimes = kx(k);

    % 初始化三个Lyapunov指数
    expo = zeros(iteratetimes,3);

    for i=1:iteratetimes 
        tend = tstart + st;
        [~,Y] = ode45(@lorenz_ode,[tstart,tend], y);

        % 取积分得到的最后一个时刻的值
        y = Y(size(Y,1),:);
        y0 = [y(4) y(7) y(10);
              y(5) y(8) y(11);
              y(6) y(9) y(12)];
        %正交化
        [y0,znorm] = GS(y0);
        sum = sum + log(znorm);
        y(4:12) = y0;

        %三个Lyapunov指数
        for j=1:3
            expo(i,j) = sum(j)/(i*st);
        end
        % 重新定义起始时刻
        tstart = tend;
    end

    lyap(k,:) = expo(length(expo),:);
end

abserr=zeros(10,3);
for i=1:10
    abserr(i,:)=abs(lyap(i,:)-[0.9,0,-14.57]);
end

%plot
plot(kx,abserr,'LineWidth',1.5)
legend('Error \lambda_1','Error \lambda_2','Error \lambda_3')
legend('boxoff')
xlabel('\fontsize{14}Iteration times')
ylabel('\fontsize{14}Absolute error')
print(gcf,'-dpng','absErrIterTimes.png')