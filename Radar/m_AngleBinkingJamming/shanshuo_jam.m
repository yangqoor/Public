% 闪烁干扰
clear variables;
close all;
%仿真时间步长
fs    = 1e8;
ts    = 1 / fs;
%雷达脉宽
tao   = 2e-6;
% 仿真时间
t1    = 0:ts:tao;
%雷达脉冲重复周期
Tr    = 6e-4;
% 导弹跟踪下限  (c*tao)/2
Rmin  = 300;
% 弹目初始距离
R0    = 8e3;
% 目标初始角度
f0    = 60;
% 导引头天线指向
f1    = 60;
% 导引头速度
v_m   = 600;
%目标速度
v_t   = 300;
%目标起始点坐标
x_t0  = R0 * cos(f0 * pi / 180);
y_t0  = R0 * sin(f0 * pi / 180);
%目标速度分量
v_tx  = 300;
v_ty  = 0;
% 拖曳线长
L     = 100;
% 雷达起始点坐标
x_m0  = 0;
y_m0  = 0;
% % 雷达初始速度分量
% v_mx(1)=600*cos(f0*pi/180);
% v_my(1)=600*sin(f0*pi/180);
%电磁波速度
c     = 3e8;
%雷达发射功率
Pt    = 1e4;
% 目标方向导引头发射天线增益
Gt    = 1e3;
% 导引头接收天线增益
Gr    = 1e3;
% 导引头工作波长
h     = 0.03;
%诱饵发射功率
Pj    = 6.5;
% 诱饵发射增益
Gj    = 1;
% 目标雷达截面积
rcs0  = 5;
%雷达发射机和接收机综合损耗
ls1   = 10; ls2 = 10;
% 中放输出频率  需要改
fc    = 1e7;
%目标起伏类型
rcs_k = 0;
rcs   = qfmx(rcs_k, rcs0);
%波尔兹曼常数
k     = 1.38e-23;
%接收机等效温度290K
T0    = 290;
%接收机噪声系数
Nf    = 3;
% 接收机中放带宽
Bn    = 1e6;
% 中放增益
G     = 1e6;
N0    = k * T0 * Bn * Nf; % 接收机噪声的方差
% 定向斜率    6.7461
n     = 0.5917;
% 比例制导系数
K     = 2;
%% 程序
k     = length(t1);
s     = cos(2 * pi * fc * t1);
zsh(1, :) = G * noise2(N0, tao, fs, t1);
Am(1)   = 55;
fh(1)   = f1;
fwt(1)  = f0;
xt(1)   = x_t0;
yt(1)   = y_t0;
v_mx(1) = v_m * cos(Am(1) * pi / 180);
v_my(1) = v_m * sin(Am(1) * pi / 180);
xm(1)   = x_m0;
ym(1)   = y_m0;
Rt(1)   = R0;
[G_h_t, G_fwch_t] = hchwl(f1, f0);
A_h_t(1) = G * sqrt((Pt * Gt * Gr * (G_h_t^2) * (h)^2 * rcs) / ((4 * pi)^3 * Rt(1)^4 * ls1 * ls2)); %和支路振幅
A_fwch_t(1) = G * sqrt((Pt * Gt * Gr * G_h_t * G_fwch_t * (h)^2 * rcs) / ((4 * pi)^3 * Rt(1)^4 * ls1 * ls2));
S_h_tw(1) = (A_h_t(1))^2 / (G^2);
S_h_t(1, :) = A_h_t(1) .* s;
S_fwch_t(1, :) = sign((fwt(1) - fh(1))) * A_fwch_t(1) .* s;
% 诱饵
xd(1) = xt(1) + L * cos(5 * pi / 180);
yd(1) = yt(1) - L * sin(5 * pi / 180);
Rd(1) = sqrt((xd(1) - xm(1))^2 + (yd(1) - ym(1))^2);
fwd(1) = (atan((yd(1) - ym(1)) / (xd(1) - xm(1)))) * 180 / pi;
[G_h_d, G_fwch_d] = hchwl(f1, fwd(1));
A_h_d(1) = G * sqrt((Pj * Gj * Gr * G_h_d * (h)^2) / ((4 * pi)^2 * Rd(1)^2 * ls1 * ls2)); %和支路
A_fwch_d(1) = G * sqrt((Pj * Gj * Gr * G_fwch_d * (h)^2) / ((4 * pi)^2 * Rd(1)^2 * ls1 * ls2));
S_h_dw(1) = (A_h_d(1))^2 / (G^2);
JS(1) = S_h_dw(1) / S_h_tw(1);
pian(1) = S_h_dw(1) / (S_h_dw(1) + S_h_tw(1));
SNR0 = S_h_tw(1) / N0;
S_h_d(1, :) = A_h_d(1) .* s;
S_fwch_d(1, :) = sign((fwd(1) - fh(1))) * A_fwch_d(1) .* s;
S_h_r(1, :) = S_h_t(1, :) + S_h_d(1, :) + zsh(1, :);
S_fwch_r(1, :) = S_fwch_t(1, :) + S_fwch_d(1, :) + zsh(1, :);
S_r1 = max(abs(S_h_r(1, :)));
S_h_r1(1, :) = S_h_r(1, :) / S_r1;
S_fwch_r1(1, :) = S_fwch_r(1, :) / S_r1;
v(1) = xwjb(S_fwch_r1(1), S_h_r1(1), fs, tao, t1, fc);
load shuju f u;
u_j = u(2001:5001);
ch = abs(v(1) - u_j);
[zx, xb] = min(ch);
det1(1) = f(xb + 2000);
det(1) = det1(1);
T = 10 * Tr;
flag = 1;
j = 1;
N = 200; %设置闪烁周期
% i=1:8;
for t = 0:T:20000 * T
    %接收机噪声
    zsh(j + 1, :) = noise2(N0, tao, fs, t1);
    % N(j+1)=noise(t);
    fh(j + 1) = fh(j) + det(j);
    % 雷达速度分量
    v_mx(j + 1) = v_m * cos(Am(j) * pi / 180);
    v_my(j + 1) = v_m * sin(Am(j) * pi / 180);
    %雷达运动轨迹
    xm(j + 1) = xm(j) + v_mx(j + 1) * T;
    ym(j + 1) = ym(j) + v_my(j + 1) * T;
    %目标运动轨迹
    xt(j + 1) = xt(j) - v_tx * T;
    yt(j + 1) = yt(j) - v_ty * T;
    Rt(j + 1) = sqrt((xt(j + 1) - xm(j + 1))^2 + (yt(j + 1) - ym(j + 1))^2);

    if ((yt(j + 1) - ym(j + 1)) < 0) | ((xt(j + 1) - xm(j + 1)) < 0)
        fwt(j + 1) = (pi + atan((yt(j + 1) - ym(j + 1)) / (xt(j + 1) - xm(j + 1)))) * 180 / pi;
    else
        fwt(j + 1) = (atan((yt(j + 1) - ym(j + 1)) / (xt(j + 1) - xm(j + 1)))) * 180 / pi;
    end

    [G_h_t, G_fwch_t] = hchwl(fh(j + 1), fwt(j + 1));
    A_h_t(j + 1) = G * sqrt((Pt * Gt * Gr * (G_h_t^2) * (h)^2 * rcs) / ((4 * pi)^3 * Rt(j + 1)^4 * ls1 * ls2)); %和支路振幅
    A_fwch_t(j + 1) = G * sqrt((Pt * Gt * Gr * G_h_t * G_fwch_t * (h)^2 * rcs) / ((4 * pi)^3 * Rt(j + 1)^4 * ls1 * ls2)); %方位差支路振幅
    % for i=1:8
    %      if ((j+1)>=(i-1)*N+1)&((j+1)<=(i-1)*N+N/2)
    %      A_h_t(j+1)=0;   %和支路振幅
    %      A_fwch_t(j+1)=0;    %方位差支路振幅
    %    break;
    %     end
    % end
    S_h_tw(j + 1) = (A_h_t(j + 1))^2 / (G^2);
    S_h_t(j + 1, :) = A_h_t(j + 1) .* s;
    S_fwch_t(j + 1, :) = sign((fwt(j + 1) - fh(j))) * A_fwch_t(j + 1) .* s;
    % 诱饵轨迹
    xd(j + 1) = xt(j + 1) + L * cos(5 * pi / 180);
    yd(j + 1) = yt(j + 1) - L * sin(5 * pi / 180);

    if ((yd(j + 1) - ym(j + 1)) < 0) | ((xd(j + 1) - xm(j + 1)) < 0)
        fwd(j + 1) = (pi + atan((yd(j + 1) - ym(j + 1)) / (xd(j + 1) - xm(j + 1)))) * 180 / pi;
    else
        fwd(j + 1) = (atan((yd(j + 1) - ym(j + 1)) / (xd(j + 1) - xm(j + 1)))) * 180 / pi;
    end

    Rd(j + 1) = sqrt((xd(j + 1) - xm(j + 1))^2 + (yd(j + 1) - ym(j + 1))^2);
    [G_h_d, G_fwch_d] = hchwl(fh(j + 1), fwd(j + 1));
    A_h_d(j + 1) = G * sqrt((Pj * Gj * Gr * G_h_d * (h)^2) / ((4 * pi)^2 * Rd(j + 1)^2 * ls1 * ls2)); %和支路振幅
    A_fwch_d(j + 1) = G * sqrt((Pj * Gj * Gr * G_fwch_d * (h)^2) / ((4 * pi)^2 * Rd(j + 1)^2 * ls1 * ls2)); %方位差支路振幅

    for i = 1:8

        if ((j + 1) >= (i - 1) * N + 1) & ((j + 1) <= (i - 1) * N + N / 2)
            A_h_d(j + 1) = 0; %和支路振幅
            A_fwch_d(j + 1) = 0; %方位差支路振幅
            break;
        end

    end

    S_h_dw(j + 1) = (A_h_d(j + 1))^2 / (G^2);
    JS(j + 1) = S_h_dw(j + 1) / S_h_tw(j + 1);
    S_h_d(j + 1, :) = A_h_d(j + 1) .* s;
    S_fwch_d(j + 1, :) = sign((fwd(j + 1) - fh(j))) * A_fwch_d(j + 1) .* s;

    if (abs((fwt(j + 1) - fh(j + 1))) > 3.5) & (abs((fwd(j + 1) - fh(j + 1))) < 3.5)

        if flag == 1
            dian = j + 1;
        end

        S_h_r(j + 1, :) = S_h_t(j + 1, :) + S_h_d(j + 1, :) + zsh(j + 1, :);
        S_fwch_r(j + 1, :) = S_fwch_t(j + 1, :) + S_fwch_d(j + 1, :) + zsh(j + 1, :);
        flag = 0;
    elseif (abs((fwt(j + 1) - fh(j + 1))) < 3.5) & (abs((fwd(j + 1) - fh(j + 1))) > 3.5)

        if flag == 1
            dian = j + 1;
        end

        S_h_r(j + 1, :) = S_h_t(j + 1, :) + S_h_d(j + 1, :) + zsh(j + 1, :);
        S_fwch_r(j + 1, :) = S_fwch_t(j + 1, :) + S_fwch_d(j + 1, :) + zsh(j + 1, :);
        flag = 0;
    else
        S_h_r(j + 1, :) = S_h_t(j + 1, :) + S_h_d(j + 1, :) + zsh(j + 1, :);
        S_fwch_r(j + 1, :) = S_fwch_t(j + 1, :) + S_fwch_d(j + 1, :) + zsh(j + 1, :);
    end

    Sr(j + 1) = max(abs(S_h_r(j + 1, :)));
    S_h_r1(j + 1, :) = S_h_r(j + 1, :) / Sr(j + 1);
    S_fwch_r1(j + 1, :) = S_fwch_r(j + 1, :) / Sr(j + 1);
    v(j + 1) = xwjb(S_fwch_r1(j + 1), S_h_r1(j + 1), fs, tao, t1, fc);
    % load  shuju f u;
    % u_j=u(2001:5001);
    ch = abs(v(j + 1) - u_j);
    [zx, xb] = min(ch);
    det1(j + 1) = f(xb + 2000);

    if Rt(j + 1) > Rmin | Rd(j + 1) > Rmin
        det(j + 1) = det1(j + 1);
    else
        det(j + 1) = 0;
    end

    % 比例制导
    dq(j + 1) = det(j + 1) / T;
    dAm(j + 1) = K * dq(j + 1);
    Am(j + 1) = dAm(j + 1) * T + Am(j);
    % fh(j+1)=fh(j)+det(j+1);
    if Rt(j + 1) < 30 | Rd(j + 1) < 30 | (Rt(j + 1) > Rt(j) & Rd(j + 1) > Rd(j))
        break
    end

    j = j + 1;
    % if j==126
    %     pause;
    % end
end

dt = fwt - fh;
dd = fwd - fh;
JSd = JS(dian);
ant = fwt(dian) - fh(dian);
and = fwd(dian) - fh(dian);
pianj = S_h_dw(dian) / (S_h_dw(dian) + S_h_tw(dian));
Rmt = Rt(dian);
Rmd = Rd(dian);
Rdian = sqrt((xm(dian))^2 + (ym(dian))^2);
Rtl = Rt(dian);
Rtuo = Rt(j + 1);
Rdtuo = Rd(j + 1);
RR = sqrt((xm(j + 1))^2 + (ym(j + 1))^2);
t = 0:T:T * (j);
% y=[fw;f];
figure;
plot(t, fwt, '-.k', t, fh, '-k', t, fwd, ':k');
% axis([0 7 0 40]);
grid;
xlabel('导引头工作时间(s)');
ylabel('方位角(°)');
h = legend('目标', '导弹', '诱饵');
title('导弹方位角跟踪曲线');
figure;
plot(xm, ym, '--k', xt, yt, '-k', xd, yd, '-.k');
grid;
xlabel('水平坐标(m)');
ylabel('垂直坐标(m)');
h = legend('导弹', '目标', '诱饵');
title('导弹、目标、诱饵弹道图');
