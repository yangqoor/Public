close all; clear; clc;
c      = 3e8;     %光速
fc     = 5e9;     %载波频率
B      = 200e6;   %带宽
lambda = c / fc;  %波长
Tp     = 1.5e-6;  %脉宽
Kr     = B / Tp;  %调频率
fs     = 1.6 * B; %采样率

H      = 200;     %飞机高度
Ls     = 200;     %合成孔径长度
v      = 100;     %飞机速度
Lt     = Ls / v;  %合成孔径时间

% 成像区域[X0-Xc,X0+Xc; Y0-Yc,Y0+Yc]
% 以合成孔径中心为原点，距离向为x轴，方位向为y轴
Xc = 10000;
Yc = 0;
Xo = 100;
Yo = 100;

Rc   = sqrt(H^2 + Xc^2);                                            %中心距离
Ka   = 2 * v^2 / (Rc * lambda);                                     %多普勒调频率
Bmax = Lt * Ka;                                                     %多普勒最大带宽
fa   = ceil(3 * Bmax);                                              %脉冲重复频率

Rmin = sqrt(H^2 + (Xc - Xo)^2);                                     %观测场景距飞机的最近距离
Rmax = sqrt((Xc + Xo)^2 + H^2 + (Yc + Yo + Ls / 2)^2);              %最远距离
rm   = Ls + 2 * Yo;                                                 %雷达走过的总路程长度
tm   = 0:1 / fa:rm / v - 1 / fa;                                    %慢时间（合成孔径时间+成像区域时间）
tk   = 2 * Rmin / c - Tp / 2:1 / fs:2 * Rmax / c - 1 / fs + Tp / 2; %快时间（距离门内）

target = [Xc, Yc, 0;
    Xc + 80, Yc + 45, 0;
    Xc - 20, Yc - 20, 0];                             %目标坐标
echo = zeros(length(tm), length(tk), length(target)); %回波
echo_all = zeros(length(tm), length(tk));
y = -v * (rm / v) / 2 + v * tm;                       %飞机y轴坐标

for k = 1:size(target, 1)                                                                      %目标数

    for i = 1:length(tm)                                                                       %慢时间轴
        radar = [0, y(i), H];                                                                  %飞机坐标
        Rtm = sqrt(sum((target(k, :) - radar).^2));
        echo(i, :, k) = (abs(target(k, 2) - y(i)) / Xc < 0.01) * rectpuls(tk - 2 * Rtm / c, Tp) .* ...
            exp(1j * 2 * pi * fc * (tk - 2 * Rtm / c) + 1j * pi * Kr * (tk - 2 * Rtm / c).^2); %回波模型
        %注意上边为什么是tk-tr(i)-Tp/2，而不是tk-tr(i)
    end

    echo_all = echo(:, :, k) + echo_all;
end

r = ((tk * c / 2).^2 - H^2).^(1/2);

%% 距离向匹配滤波
for i = 1:size(echo_all, 1)
    echo_all(i, :) = echo_all(i, :) .* (exp(-1j * 2 * pi * fc * tk)); %回波去载频
end

tt = 0:1 / fs:Tp - 1 / fs;
hk = exp(1j * pi * Kr * tt.^2);                                       %距离向匹配滤波器
ECHO = zeros(size(echo_all));                                         %距离向压缩之后

for i = 1:length(tm)
    ECHO(i, :) = ifft(fft(echo_all(i, :)) .* conj(fft(hk, length(tk))));
end

figure;
[R, Y] = meshgrid(r, y);
mesh(R, Y, abs(ECHO)); view(0, 90); xlim([9900 10100]);
xlabel('距离向');
% ylabel('合成孔径 (慢时间), meters');
title('距离压缩后');

ha = exp(-1j * pi * 2 * (v^2) / (lambda * Rc) * (0:1 / fa:Lt - 1 / fa).^2); %方位向匹配滤波器

for k = 1:length(tk)
    ECHO(:, k) = fftshift(fft(ECHO(:, k)));
end

%% 距离徙动修正
N = 6;                                       %插值核长度为6
ECHO_RCMC = zeros(size(ECHO));
h = waitbar(0, 'Sinc插值中......');          %生成一个进度条

for k = 1:length(tm)
    f = linspace(-fa / 2, fa / 2, length(tm));
    deltaR = (lambda * f(k) / v)^2 * Rc / 8; %注意这个f，到底是哪个f
    DU = 2 * deltaR * fs / c;
    du = DU - floor(DU);
    %     kernel_norm = sum(sinc(du-(-N/2:N/2-1)));
    for n = N / 2 + 1:length(tk) %快时间

        for m = -N / 2:N / 2 - 1

            if n + floor(DU) + m > length(tk)
                ECHO_RCMC(k, n) = ECHO_RCMC(k, n) + ECHO(k, length(tk)) * sinc(DU - m);
            else
                ECHO_RCMC(k, n) = ECHO_RCMC(k, n) + ECHO(k, n + floor(DU) + m) * sinc(du - m);
            end

        end

    end

    waitbar(k / length(tm));
end

close(h); %关闭进度条

figure;
[R, Y] = meshgrid(r, y);
mesh(R, Y, abs(ifft(ECHO_RCMC))); view(0, 90); xlim([9900 10100]);
title('距离徙动矫正')
xlabel('距离向');

%% 方位向匹配滤波
for k = 1:length(tk)
    ECHO(:, k) = abs(ifft(fft(ha, length(tm))' .* fftshift(ECHO_RCMC(:, k)))); %方位向压缩后
end

figure;
mesh(r, y, ECHO);
view(0, 90)
xlim([9900 10100]);
xlabel('距离向');
ylabel('方位向');
zlabel('幅度'); title('最终压缩结果');
