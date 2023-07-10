clear all;clc;close all;
N = 13;               % length of x[k] 
n = 0:N - 1;
xn = (0.8).^n;
sita = pi / 4;        % phase of start point 
fai = pi / 6;         % phase interval 
A = exp(j * sita);    % complex starting point 
W = exp(-j * fai);    % complex ratio between points 
M = 8;                % lenth of czt 
y = czt(xn, M, W, A); % call czt function 
subplot(2, 1, 1); stem(n, xn);
xlabel('k'); title('sequence x[k]');
m = 0:M - 1; subplot(2, 1, 2); stem(m, abs(y));
xlabel('m'); title('CZT of x[k]');
