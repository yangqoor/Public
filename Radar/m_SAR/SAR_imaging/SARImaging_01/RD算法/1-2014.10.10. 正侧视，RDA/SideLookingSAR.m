%--------------------------------------------------------%
% 正侧视SAR点目标仿真
% 点目标参数:方位向距离为0,斜距为50000,后向反射系数为1
%--------------------------------------------------------%
clc;
clear;
close all;

%--------------------------------------------------------%
%Parameter--constant
C = 3e8;

%Parameter--radar characteristics
lambda = 0.032;
v = 150;
Kv = 2;
R0 = 50000;
D = 4;
Lsar = lambda * R0 / D;
Tsar = Lsar / v;

%Parameter--slow-time domain:Azimuth
Kd = -2 * v^2 / lambda / R0;                   %doppler frequency modulation rate
Bd = abs(Kd * Tsar);                           %doppler frequency modulation bandwidth
PRF = Kv * v;                                  %pulse repitition frequency
PRT = 1 / PRF;                                 %pulse repitition time
ds = PRT;                                      %sample spacing in slow-time domain
N = ceil(Lsar / v / ds);
N = 2^nextpow2(N);                             %for fft
sn = linspace(-Lsar / 2 / v, Lsar / 2 / v, N); %discrete time array in slow-time domain
PRT = Lsar / v / N;                            %“refresh”
PRF = 1 / PRT;
ds = PRT;

%Parameter--fast-time domain:Range
Tr = 5e-6;                                      %pulse duration 10us
Br = 100e6;                                     %chirp frequency modulation bandwidth 100MHz
Kr = Br / Tr;                                   %chirp slope
Fsr = 150e6;                                    %sampling frequency in fast-time domain
dt = 1 / Fsr;                                   %sample spacing in fast-time domain
Rmin = R0;
Rmax = sqrt(R0^2 + (Lsar / 2)^2);
M = ceil(2 * (Rmax - Rmin) / C / dt + Tr / dt); %sample number in fast-time domain 回波信号持续时间为2*(Rmax-Rmin)/C+Tr
M = 2^nextpow2(M);                              %for fft
tm = linspace(2 * Rmin / C - Tr / 2, 2 * Rmax / C + Tr / 2, M); %discrete time array in fast-time domain
dt = (2 * Rmax / C + Tr - 2 * Rmin / C) / M;                    %“refresh”
Fsr = 1 / dt;

%Parameter--resolution
DY = C / 2 / Br;      %range resolution
DX = D / 2;           %cross-range resolution

%Parameter--point targets
Ptarget = [0, R0, 1]; %target position and RCS

disp('Parameters:')
disp('Sampling Rate in fast-time domain'); disp(Fsr / Br)
disp('Sampling Number in fast-time domain'); disp(M)
disp('Sampling Rate in slow-time domain'); disp(PRF / Bd)
disp('Sampling Number in slow-time domain'); disp(N)
disp('Range Resolution'); disp(DY)
disp('Azimuth Resolution'); disp(DX)
disp('Synthetic Aperture Length'); disp(Lsar)
disp('Synthetic Aperture Time'); disp(Tsar)
disp('Position of targets'); disp(Ptarget)

%--------------------------------------------------------%
%--------------------------------------------------------%
% Generate the raw signal data
Srnm = zeros(N, M);
Pa = v * sn;                                %sample position to target in slow-time domain
R = sqrt(R0^2 + (Pa).^2);                   %sample slant range
delay = 2 * R / C;                          %time delay in transmitted pulse
Pr = ones(N, 1) * tm - delay' * ones(1, M); %sample time for transmitted pulse
phase = j * pi * Kr * (Pr).^2 - j * 4 * pi / lambda * (R' * ones(1, M));
Srnm = Ptarget(1, 3) * exp(phase) .* (abs(Pr) <= Tr / 2) .* (abs(Pa' * ones(1, M)) <= Lsar / 2); %sig : target echo model 点目标回波原始数据

%--------------------------------------------------------%
%--------------------------------------------------------%
% Range compression
fr = -1/2:1 / M:(1/2 - 1 / M);
fr = fr * Fsr;
filter_r = fftshift(exp(j * pi * fr.^2 / Kr)); %matched filter in range derection

for i = 1:N
    Srnm(i, :) = ifft(fft(Srnm(i, :)) .* filter_r);
end

disp('End of range compression');
row = C * tm / 2;
col = v * sn;
colormap(gray);
figure(1);
imagesc(row, col, 255 - abs(Srnm));
xlabel('\rightarrow\itRange in meters'), ylabel('\itAzimuth in meters\leftarrow'),
title('2-d time domain after range compression'),

%--------------------------------------------------------%
%--------------------------------------------------------%
% Azimuth fft
for i = 1:M
    Srnm(:, i) = fftshift(fft(Srnm(:, i)));
end

disp('End of azimuth fft');
% RCMC
fa = -1/2:1 / N:(1/2 - 1 / N);
fa = fa * PRF;
deteR = 2 / C * (lambda^2 * R0 * fa.^2/8 / v^2) * Fsr; % 距离徙动所占的采样点数,不一定为整数值,所以接下来要进行插值
N_interp = 8; %N_interp=8表示以8倍进行插值
N_ex = 1000; %N_ex必须大于距离徙动所占的采样点数

for i = 1:N
    newp = round(((1:M) + deteR(i) - 1) * N_interp + 1); %round表示四舍五入取整
    Srnm_interp = zeros(size(1:M * N_interp + N_ex));
    Srnm_interp(1:M * N_interp) = interp(Srnm(i, :), N_interp); %interp表示插值,详见help interp
    Srnm(i, :) = Srnm_interp(newp);
end

disp('End of RCMC');
colormap(gray);
figure(2);
imagesc(row, col, 255 - abs(Srnm));
xlabel('\rightarrow\itRange in meters'), ylabel('\itAzimuth in meters\leftarrow'),
title('r-d domain after interpolation');

%--------------------------------------------------------%
%--------------------------------------------------------%
% Azimuth compression
fa = -1/2:1 / N:(1/2 - 1 / N);
fa = fa' * PRF;
filter_a = exp(-j * pi * fa.^2 / abs(Kd)); %matched filter in azimuth derection

for i = 1:M
    Srnm(:, i) = ifft(fftshift(Srnm(:, i) .* filter_a));
end

disp('End of azimuth compression');
colormap(gray);
figure(3);
imagesc(row, col, 255 - abs(Srnm));
xlabel('\rightarrow\itRange in meters'), ylabel('\itAzimuth in meters\leftarrow'),
title('2-d time domain after azimuth compression');

figure(4);
mesh(row(450:550), col(450:550), abs(Srnm(450:550, 450:550))); axis tight;
xlabel('\rightarrow\itRange in meters'), ylabel('\itAzimuth in meters\leftarrow'),
title('2-d time domain after azimuth compression');
