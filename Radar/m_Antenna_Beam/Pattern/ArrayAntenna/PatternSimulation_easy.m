clc
clear
close all
% ===========1-D===============
sita = -pi / 2:0.001:pi / 2; % θ取-pi/2到pi/2
D = 2;
d = 0.1;                     % d就是积分用的那个dx
lamda = 0.05;                % λ取0.05，波长

sum = 0;
len = length(sita);
pattern = zeros(1, len);
i = 1;

for sita = -pi / 2:0.001:pi / 2

    for x = -D / 2:d:D / 2
        sum = sum + exp(1j * 2 * pi * sin(sita) * x / lamda) * d; % 这个是积分的过程，用求和实现
    end

    pattern(i) = sum;
    i = i + 1;
    sum = 0; % 此循环后，每个pattern（i）都被更新，每个值是关于特定θ对应的值，即这是关于θ的函数
end

figure(1);
sita = linspace(-pi / 2, pi / 2, len);
plot(sin(sita), abs(pattern));
title('1-D 雷达方向图');

% ============2-D================
clc
clear

size = 2000;

A = zeros(size, size);

for m = 1:10

    for n = 1:10
        A(m, n) = 1;
    end

end

A = circshift(A, [size * 0.5 - 5, size * 0.5 - 5]); % 循环移位，把左上角10*10的全1 矩阵弄到A的正中央
x = 1:size;
y = 1:size;
z = fftshift(abs(fft2(A))); % 直接做2-D fft  理论见课堂笔记本上的记录

figure(2);
h1 = mesh(x, y, z);         % mesh 是画三维图的函数
view([0, 0, 1]);            % 0 0 -1 分别表示在直角坐标系中，从坐标（0 0 -1）处看上面生成的三维图
title('(2-D)矩形面天线方向图俯视图');
grid on;
figure(3);
h2 = mesh(x, y, z);
view([1, 1, 1]);            % 形象的看一看这个方向图
title('(2-D)矩形面天线方向图斜视图');
