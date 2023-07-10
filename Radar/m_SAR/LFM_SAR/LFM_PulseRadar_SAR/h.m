clear all;
close all;
clc;
N = 10^0;
Pfa = 10^(-3);
noise = N / sqrt(2) * (randn(1, 10^4) + 1i * randn(1, 10^4));
Thr = sqrt(-N^2 * log(Pfa));
abs_noise = abs(noise);
%白噪声的波形
figure(1)
plot(abs_noise);
title('白噪声的波形及阈值');
hold on
plot(0:10000, Thr, 'r');
Diff = abs_noise - Thr;
index = find(Diff > 0);
M = length(index);
Pf = M / 10000;
disp(['虚警概率为:', num2str(Pf), '%']);
% abs_noise(5000)=abs_noise(5000)+100;
% figure(2)
% plot(abs_noise);
% title('波形及阈值');
% hold on
% plot(0:10000,Thr,'r');
% if abs_noise(5000)-Thr>0
%     disp('能检测出5000米处的目标');
% end
for m = 1:20
    k = 0;
    SNR = m - 1;
    A = 10 * (SNR / 20);
    abs_noise(5000) = abs_noise(5000) + A;
    Thr1 = sqrt(-log(Pf));

    for m1 = 1:1000

        if abs_noise(5000) > Thr1
            k = k + 1;
        end

    end

    Pd(m) = k / 1000;
end

figure(3)
axis([0 20 0 1]);
plot(Pd);
grid;
