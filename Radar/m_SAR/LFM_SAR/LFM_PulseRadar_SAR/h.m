clear all;
close all;
clc;
N = 10^0;
Pfa = 10^(-3);
noise = N / sqrt(2) * (randn(1, 10^4) + 1i * randn(1, 10^4));
Thr = sqrt(-N^2 * log(Pfa));
abs_noise = abs(noise);
%�������Ĳ���
figure(1)
plot(abs_noise);
title('�������Ĳ��μ���ֵ');
hold on
plot(0:10000, Thr, 'r');
Diff = abs_noise - Thr;
index = find(Diff > 0);
M = length(index);
Pf = M / 10000;
disp(['�龯����Ϊ:', num2str(Pf), '%']);
% abs_noise(5000)=abs_noise(5000)+100;
% figure(2)
% plot(abs_noise);
% title('���μ���ֵ');
% hold on
% plot(0:10000,Thr,'r');
% if abs_noise(5000)-Thr>0
%     disp('�ܼ���5000�״���Ŀ��');
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
