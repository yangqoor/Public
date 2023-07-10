clear all;
close all;
clc;
%%参数
fc = 10e9;              %载波频率
Tp = 10e-6;             %脉冲宽度
B = 10e6;               %信号带宽
fs = 1e8;               %采样率
R = 3000;               %初始采样距离
c = 3e8;                %光速
PRT = 100e-6;           %脉冲重复周期
CPI = 64;               %总脉冲个数
v = 60;                 %目标运动速度

%%有噪
ta0 = 2 * R / c;        %快时间时延
Kr = B / Tp;            %线性调频斜率
t = 0:1 / fs:Tp + ta0;  %时域范围
M = length(t);
N = 100/10^(10/20);
s = zeros(64, M);

for k1 = 1:64
    ta = 2 * (R - (k1 - 1) * PRT * v) / c;
    s_back = 100 * rectpuls(t - ta - Tp / 2, Tp) .* exp(1i * pi * Kr * (t - Tp / 2 - ta).^2) .* exp(-1i * 2 * pi * fc * ta);
    noise = N / sqrt(2) * (randn(1, M) + 1i * randn(1, M));
    S_back = s_back + noise; %含噪声的回波信号
    refer = rectpuls(t - Tp / 2, Tp) .* exp(1i * pi * Kr * (t - Tp / 2).^2);
    S3 = fft(S_back);
    S4 = fft(refer);
    S = S3 .* conj(S4);
    s1(k1, :) = ifft(S); %压缩后的回波信号
    s(k1, :) = s1(k1, :) / max(s1(k1, :)); %归一化
    s(k1, :) = db(s(k1, :));
end

F_S = zeros(64, M);

for m = 1:M
    F_S(:, m) = fftshift(abs(fft(s1(:, m))));
end

%%最大值法 测速测距
[maxrow, maxcol] = find(F_S == max(max(F_S))); %所在行列
range1 = maxcol * c / 2 / fs;
fd = (maxrow - 33) / CPI / PRT;
lamda = c / fc;
Vr = fd * lamda / 2;
%%形心法 测速，测距
%测距
index = maxcol - 5:maxcol + 5;
Amp = F_S(maxrow, index);
range2 = index * c / 2 / fs;
range0 = sum(range2 .* Amp) / sum(Amp);
%测速
index = maxrow - 2:maxrow + 2;
Amp = F_S(index, maxcol).';
fd = (index - 33) / CPI / PRT;
Vlist = fd * lamda / 2;
V0 = sum(Vlist .* Amp) / sum(Amp);

%%显示结果
disp(['目标回波有噪声时最大值法测的距离为:', num2str(range1), 'm']);
disp(['目标回波有噪声时最大值法测的速度为:', num2str(Vr), 'm/s']);
disp(['目标回波有噪声时形心法测的距离为:', num2str(range0), 'm']);
disp(['目标回波有噪声时形心法测的速度为:', num2str(V0), 'm/s']);
