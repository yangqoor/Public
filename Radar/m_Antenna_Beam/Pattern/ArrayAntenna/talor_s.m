SLL = -30;
N = 13;
R0 = 10^(-SLL / 20); A = (1 / pi) * acosh(R0); n1 = ceil(2 * A^2 + 1/2 + 1); sigma = n1 / sqrt(A^2 + (n1 - 1/2)^2);

for n = 1:1:n1 - 1;
    Xn(n) = n1 * sqrt((A^2 + (n - 1/2)^2) / (A^2 + (n1 - 1/2)^2));
end

for n = n1:1:N;
    Xn(:, n) = n;
end

theta_rad = 0:0.01:pi;
theta = theta_rad * 180 / pi;
lamda = 1; d = lamda / 2; L = N * d; Xu = L * cos(theta_rad) / lamda;

for n = 1:1:n1 - 1;
    Sx0(:, n) = 1 - ((Xu.^2) ./ (Xn(n).^2));
end

Sx0_p = prod(Sx0');

for n = 1:1:n1 - 1;
    Sx1(:, n) = 1 - ((Xu.^2) ./ (n.^2)); %二维数组
end

Sx1_p = prod(Sx1');
Sx = cosh(pi * A) .* (((sin(pi * Xu) .* Sx0_p) ./ ((pi * Xu) .* Sx1_p)));
Sx_max = max(Sx);
SxdB = 20 * log10((abs(Sx)) / Sx_max); %归一化方向图
figure(1);
plot(theta, SxdB);
title('泰勒线阵相对幅度方向图');
