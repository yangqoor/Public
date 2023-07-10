% 求天线仿真中使用泰勒综合法，计算泰勒天线综合的电流分布
clc;clear;close all

N = 13;                                          % N 3<N<=13,N
if rem(N, 2) == 0                                % M( )
    M = N / 2;
else
    M = (N - 1) / 2 + 1;
end
RdB = 30;                                        % (dB )
lamuda = 10;                                     %
d = 0.6 * lamuda;                                %
theta0 = 80/180 * pi;
A = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
    0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
    -1, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
    0, -3, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
    1, 0, -8, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0;
    0, 5, 0, -20, 0, 16, 0, 0, 0, 0, 0, 0, 0, 0;
    -1, 0, 18, 0, -48, 0, 32, 0, 0, 0, 0, 0, 0, 0;
    0, -7, 0, 56, 0, -112, 0, 64, 0, 0, 0, 0, 0, 0;
    1, 0, -32, 0, 160, 0, -256, 0, 128, 0, 0, 0, 0, 0;
    0, 9, 0, -120, 0, 432, 0, -576, 0, 256, 0, 0, 0, 0;
    -1, 0, 50, 0, -400, 0, 1120, 0, -1280, 0, 512, 0, 0, 0;
    0, -11, 0, 220, 0, -1232, 0, 2816, 0, -2816, 0, 1024, 0, 0;
    1, 0, -72, 0, 840, 0, -3584, 0, 6912, 0, -6144, 0, 2048, 0;
    0, 13, 0, -364, 0, 2912, 0, -9984, 0, 16640, 0, -13312, 0, 4096];
I = zeros(1, M);                                 %
S = zeros(M, M);                                 %
S_compare = zeros(1, M);                         %
R = 10^(RdB / 20);                               % dB
x0 = 1/2 * ((R + sqrt(R^2 - 1))^(1 / (N - 1)) + (R - sqrt(R^2 - 1))^(1 / (N - 1)));
for i = 1:M
    if rem(N, 2) == 0                            %
        for j = 1:M                              % i x i
            S(i, j) = A(2 * j, 2 * i);           % j j x0)
        end
        S_compare(i) = A(N, 2 * i);              % N-1 chebyshev
    else                                         %
        for j = 1:M
            S(i, j) = A(2 * j - 1, 2 * i - 1);
        end
        S_compare(i) = A(N, 2 * i - 1);
    end
end
for k = 1:M
    i = M - k + 1;
    if rem(N, 2) == 0                            %
        I(i) = (S_compare(i) * x0^(2 * i - 1) -I * S(i, :)') / S(i, i);
    else                                         %
        I(i) = (S_compare(i) * x0^(2 * (i - 1)) -I * S(i, :)') / S(i, i);
    end
end
I = I / max(I);                                  % I
if rem(N, 2) == 0
    I_final = [fliplr(I), I];                    %
else
    I_final = [fliplr(I), I(2:end)];
end
sprintf(' ')
sprintf('%.3f ', I_final)
theta_rad = 0:0.01:pi;
theta = theta_rad * 180 / pi;
u = pi * d / lamuda * cos(theta_rad);
S_P = zeros(1, length(theta_rad));               %
for k = 1:M
    if rem(N, 2) == 0
        S_P = S_P + I(k) * cos((2 * k - 1) * u); %
    else
        S_P = S_P + I(k) * cos(2 * (k - 1) * u); %
    end
end
S_P_abs = abs(S_P);                              % S_P
S_PdB = 20 * log10(S_P_abs / 1);                 % S_P dB
H = -ones(1, length(S_P_abs)) * 30;
figure('NumberTitle', 'off', 'Name', 'S Parameter (abs)-Plot');
plot(theta, S_P_abs, 'b', 'LineWidth', 1.5)
xlabel('theta( ')
ylabel('|S| ')
title('chebyshev ')
figure('NumberTitle', 'off', 'Name', 'S Parameter (dB)-Plot');
plot(theta, H, 'r--', 'LineWidth', 1.5)
hold on
plot(theta, S_PdB, 'b', 'LineWidth', 1.5)
xlabel('theta( ')
ylabel('|S| dB')
title('chebyshev ')
legend(' ', ' ')
figure('NumberTitle', 'off', 'Name', 'S Parameter (dB)-Polar');
polarplot(theta_rad, H, 'r--', 'LineWidth', 1.5)
hold on
polarplot(theta_rad, S_PdB, 'b', 'LineWidth', 1.5)
thetalim([0 180]);
rmin = S_PdB(1, 1);
rmax = max(S_PdB);
rlim([-50 rmax]);
title('chebyshev ')
legend(' RdB', ' (dB)')
