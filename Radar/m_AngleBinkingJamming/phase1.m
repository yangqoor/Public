% 相位检波器模型
clear variables;
close all;
%% 输入变量
%电磁波速度
c = 3e8;
%雷达发射功率
Pt = 8e3;
% 目标方向导引头发射天线增益
Gt = 40;
% 导引头接收天线增益
Gr = 40;
% 导引头工作波长
h = 0.03;
% 目标雷达截面积
rcs0 = 5;
%雷达发射机和接收机综合损耗
ls1 = 1; ls2 = 1;
% 弹目初始距离
R = 8e3;
% 导引头速度
v_r = 900;
%目标速度
v_t = 300;
%雷达脉冲重复周期
Tr = 6e-4;
%雷达脉宽
tao = 2e-6;
%仿真时间步长
fs = 1e8;
ts = 1 / fs;
% 仿真时间
t = 0:ts:tao;
% 中放输出频率
fc = 1e7;
% 中放增益
G = 1e6;
%目标起伏类型
rcs_k = 0;
rcs = qfmx(rcs_k, rcs0);
fd = 2 * (v_r + v_t) / h; %多普勒频移
tr = 2 * R / c; %回波时延
wc = 2 * pi * fc;
% 程序
s = cos(2 * pi * fc * t);
fw = 8.5:0.001:15.5;
len = length(fw);

for j = 1:len
    [G_h, G_fwch] = hchwl(12, fw(j));
    % S_h_r=G*sqrt((Pt*Gt*Gr*(G_h^2)*(h)^2*rcs)/((4*pi)^3*R^4*ls1*ls2)).*s;     %和支路
    % S_fwch_r=sign((fw-12))*G*sqrt((Pt*Gt*Gr*G_h*G_fwch*(h)^2*rcs)/((4*pi)^3*R^4*ls1*ls2)).*s;    %方位差支路
    A_h = G * sqrt((Pt * Gt * Gr * (G_h^2) * (h)^2 * rcs) / ((4 * pi)^3 * R^4 * ls1 * ls2));
    A_fwch = G * sqrt((Pt * Gt * Gr * G_h * G_fwch * (h)^2 * rcs) / ((4 * pi)^3 * R^4 * ls1 * ls2));
    S_h = A_h .* s; %和支路
    S_fwch = sign((fw(j) - 12)) * A_fwch .* s; %方位差支路
    % S=max(abs(S_h));
    S_h_1 = S_h / A_h;
    S_fwch_1 = S_fwch / A_h;
    u(j) = xwjb_2(S_fwch_1, S_h_1, fs, tao, t, fc);
    % A=abs((A_h/A_h)-(A_fwch/A_h));
    % if A>0.5
    %    u(j)=xwjb(S_fwch_1,S_h_1,fs,tao,t,fc);
    % else
    %     u(j)=xwjb_2(S_fwch_1,S_h_1,fs,tao,t,fc);
    % end
    % if j==5000;
    %     pause;
    % end
end

f = -3.5:0.001:3.5;
figure;
plot(f, u);
% axis([-4 4 -0.3 0.3]);
grid;
xlabel('误差角(°)');
ylabel('误差电压');
save shuju f u;
