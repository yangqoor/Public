clear;clc;
sigma = 1;
x = sigma .* randn(100000,1);
figure(1)
ksdensity(x);grid on;title('概率分布 \sigma = 1')