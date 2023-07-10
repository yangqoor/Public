clc;
close all;
st = linspace(-0.15, 0.15, 1000);
std = (st .* 180) ./ pi;
std = linspace(-5, 5, 1000);
d = 0.05;
N = 1000;
lm = 1;
l = 50;
R = 50000;
y1 = sin((pi .* N .* d .* sin(st)) ./ lm);
y2 = ((pi .* N .* d .* sin(st)) ./ lm);
y8 = y1 ./ y2; %y为普通雷达方向图函数F
y = 10 .* log(y8);

plot(std, y);
title('雷达方向图函数');
xlabel('方位角/（°）')
ylabel('增益/db')
ste = l ./ (2 .* R); %将ste变为弧度
y11 = sin((pi .* N .* d .* sin(st - ste)) ./ lm);
y22 = ((pi .* N .* d .* sin(st - ste)) ./ lm);
yy = y11 ./ y22; %F(st-ste)
y111 = sin((pi .* N .* d .* sin(st + ste)) ./ lm);
y222 = ((pi .* N .* d .* sin(st + ste)) ./ lm);
yyy = y111 ./ y222; %F(st+ste)
yhe = yy + yyy; %未做相位变换的和通道
yhee = 10 .* log(yhe);
ycha = yy - yyy; %未做相位变换的差通道
ychaa = 10 .* log(ycha);
figure
plot(std, yhee);
title('相位未转换的和通道响应');
xlabel('方位角/（°）')
ylabel('和信号功率/db')
figure
plot(std, ychaa);
title('相位未转换的差通道响应');
xlabel('方位角/（°）')
ylabel('差信号功率/db')
