%此程序实现了线阵8阵元的和差波束测角，利用全阵同时形成两个波束，形成和差波束
%随着测量角度的增大其误差也逐渐增大，这是由于这种方法的近似所致和波束扫描时变胖

%%%%%%%%%%%%%%%%%%%%%
%%扫描信号方向与起始角度差别，从而画出误差曲线
%%%%%%%%%%%%%%%%%%%%%
close all;
clear;
clc;

ele    = 8;   %阵元数
d_lama = 0.5;
theta1 = 10;  %起始角度

detal  = 0.1; %偏角扫描增量
i      = 0;
x      = 5:detal:15;

err0   = zeros(1, length(x));
err1   = zeros(1, length(x));
rate_i = zeros(1, length(x));
diff   = 3;   %两个波束相对等信号轴的偏角

for thetal_singal = 30 % 信号方向
    i = i + 1;
    theta2 = [theta1 - diff theta1 + diff] * pi / 180;

    %%%%%%%%%%误差的大小与信号方向和diff有关系：thetal_singal=1;diff=7;
    %                                           thetal_singal=2;diff=7;
    %                                           thetal_singal=0.5;diff=7;
    %%%%%%%%%%信号方向与起始角度差别越小越精确
    %%%%%%%%%%当起始信号大时候，diff越小越精确
    %%%%%%%%%%%导向矢量
    a1 = exp(j * pi * (0:ele - 1).' * sin(theta2(1)));
    a2 = exp(j * pi * (0:ele - 1).' * sin(theta2(2)));

    % a_singal=exp(j*pi*(0:ele-1).'*sin(thetal_singal*pi/180));

    alfa = linspace(-pi / 2, pi / 2, 1000);
    a = exp(j * pi * (0:ele - 1).' * sin(alfa));

    % wn1=chebwin(ele,40);%切辟雪夫权00000
    % wn2=0.54-0.46*cos(2*pi*(0:ele-1)/(ele-1));%海明权
    % a1=diag(wn1)*a1;
    % a2=diag(wn1)*a2;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%利用公式计算角度

    a_singal = exp(j * pi * (0:ele - 1).' * sin(thetal_singal * pi / 180));
    p1_singal = a1' * a_singal;
    p2_singal = a2' * a_singal;
    g_sum_singal = abs(p1_singal) + abs(p2_singal);
    g_diff_singal = abs(p1_singal) - abs(p2_singal);
    % sum_gain=g_sum(thetal_singal*pi/180/pi/2*500);
    % diff_gain=g_diff(thetal_singal*pi/180/pi/2*500);
    rate = (g_diff_singal / g_sum_singal);
    % 8.4*2
    % alfa1_semi=0.886*2/7*csc(theta1*pi/180);
    % alfa1_semi=acos(cos(theta1*pi/180)-0.443*2/7)-acos(cos(theta1*pi/180)+0.443*2/7);
    F_thetal = sin(ele * pi * d_lama * (sin(theta1 * pi / 180) - sin(theta2(1)))) / ((sin(pi * d_lama * (sin(theta1 * pi / 180) - sin(theta2(1))))));
    % F_diff=diff('sin(ele*2*pi*d_lama*sin(thetal*pi/180))/(ele*2*(sin(pi*d_lama*sin(thetal*pi/180))))');
    % x=thetal;
    a_thetal = exp(j * pi * (0:ele - 1).' * sin(theta1 * pi / 180));

    if rate > 0
        F_thetal_thetal = abs(a2' * a_thetal);
        F_diff_theta = (cos(ele * pi * 1/2 * (sin(theta1 * pi / 180) - sin(theta2(2)))) * ele * pi * 1/2 * cos(theta1 * pi / 180) ...
            * sin(pi * 1/2 * (sin(theta1 * pi / 180) - sin(theta2(2)))) ...
            -sin(ele * pi * 1/2 * (sin(theta1 * pi / 180) - sin(theta2(2)))) ...
            * cos(pi * 1/2 * (sin(theta1 * pi / 180) - sin(theta2(2)))) ...
            * pi * 1/2 * cos(theta1 * pi / 180)) / (sin(pi * 0.5 * (sin(theta1 * pi / 180) - sin(theta2(2))))^2);
    end

    if rate < 0
        F_thetal_thetal = abs(a1' * a_thetal);
        F_diff_theta = (cos(ele * pi * 1/2 * (sin(theta1 * pi / 180) - sin(theta2(1)))) * ele * pi * 1/2 * cos(theta1 * pi / 180) ...
            * sin(pi * 1/2 * (sin(theta1 * pi / 180) - sin(theta2(1)))) ...
            -sin(ele * pi * 1/2 * (sin(theta1 * pi / 180) - sin(theta2(1)))) ...
            * cos(pi * 1/2 * (sin(theta1 * pi / 180) - sin(theta2(1)))) ...
            * pi * 1/2 * cos(theta1 * pi / 180)) / (sin(pi * 0.5 * (sin(theta1 * pi / 180) - sin(theta2(1))))^2);
    end

    rate_i(i) = rate;
    % F_thetal_thetal=(F_thetal+F_theta2)/2;
    %  F_diff_theta=(abs(F_diff_thetal)+abs(F_diff_theta2))/2;
    theta_cal = rate * F_thetal_thetal / abs(F_diff_theta);
    theta_cal = abs(theta_cal * 180 / pi);

    format short

    if rate >= 0
        fprintf('信号方向为法向偏左\n')
        fprintf('真实的信号方向:%2f(度)\n', thetal_singal)
        fprintf('计算的信号方向:%2f(度)\n', theta1 - theta_cal)
        fprintf('计算的绝对误差:%2f(度)\n', abs(theta1 - theta_cal) - abs(thetal_singal))
        fprintf('计算的相对误差:%2f\n', (abs(theta1 - theta_cal) - abs(thetal_singal)) / abs(thetal_singal))
    end

    if rate < 0
        fprintf('信号方向为法向偏右\n')
        fprintf('真实的信号方向:%2f(度)\n', thetal_singal)
        fprintf('计算的信号方向:%2f(度)\n', theta1 + theta_cal)
        fprintf('计算的绝对误差:%2f(度)\n', abs(theta1 + theta_cal) - abs(thetal_singal))
        fprintf('计算的相对误差:%2f\n', (abs(theta1 + theta_cal) - abs(thetal_singal)) / abs(thetal_singal))
    end

end

A = zeros(1000, 1000);
A1 = a1' * a;
A2 = a1' * a;

for i = 1:1000

    for j = 1:1000
        A(i, j) = abs(A1(i)) .* abs(A2(j));
    end

end

B = zeros(1000, 1000);
B1 = a2' * a;
B2 = a1' * a;

for i = 1:1000

    for j = 1:1000
        B(i, j) = abs(B1(i)) .* abs(B2(j));
    end

end

C = zeros(1000, 1000);
C1 = a2' * a;
C2 = a2' * a;

for i = 1:1000

    for j = 1:1000
        C(i, j) = abs(C1(i)) .* abs(C2(j));
    end

end

D = zeros(1000, 1000);
D1 = a1' * a;
D2 = a2' * a;

for i = 1:1000

    for j = 1:1000
        D(i, j) = abs(D1(i)) .* abs(D2(j));
    end

end

E = A + D - B - C; % 方位差
E1 = A + B - C - D; % 俯仰差
E2 = A + B + C + D; % 和
alfa1 = alfa * 180 / pi;
[x, y] = meshgrid(alfa1, alfa1);
figure
mesh(x, y, E);
title('方位差波束')
xlabel('角度')
ylabel('角度')
zlabel('增益')
figure
mesh(x, y, E1);
title('俯仰差波束')
xlabel('角度')
ylabel('角度')
zlabel('增益')
figure
mesh(x, y, E2);
title('和波束')
xlabel('角度')
ylabel('角度')
zlabel('增益')
