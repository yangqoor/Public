% zaituiguang.m这段代码整体上是为了通过数值方法验证两个问题的解。
% 
% 首先，通过计算矩阵k和向量g1的线性方程组的解f1，验证了在给定的条件下，方程组的解
% 是否能够近似满足要求。这个验证是通过求解正规方程 
% (k' * k + r * (l' * l)) \ k' * g1' 的数值解f1来完成的。
% 这个方程组可能代表某个物理问题或优化问题，而代码中通过数值计算来验证解的有效性。
% 
% 类似地，通过计算矩阵k和向量g2的线性方程组的解f2，也是为了验证另一个问题的解。
% 
% 整体而言，这段代码的目的是利用数值计算方法验证给定条件下两个问题的解是否能够通过
% 线性方程组的求解得到。

m = 101;n = 101;
x = linspace(0, 5, m);
y = linspace(0, 5, n);
k = zeros(m,n);

for i = 1:m

    for j = 1:n
        k(i, j) = exp(-abs(x(i) - y(j))) * 0.05;
    end

end

l = zeros(98, 101);
l(1, 1:4) = [-1 3 -3 1];

for i = 2:98

    for j = 2:101
        l(i, j) = l(i - 1, j - 1);
    end

end

g1 = (5.5 - x) .* exp(x) - 0.5 .* exp(-x);
g2 = (5.5 - x) .* exp(x) - 0.5 .* exp(-x) + 0.5 * (sin(10 .* x + 1) + cos(23 .* x + 2));

r = 6;

f1 = (k' * k + r * (l' * l)) \ k' * g1';
f2 = (k' * k + r * (l' * l)) \ k' * g2';

plot(x, f1, 'b'); hold on;
plot(x, f2, 'r');
legend('f1', 'f2', 'Location', 'best');
title('原始f1与f2', 'FontName', 'Times New Roman', 'FontSize', 14);
xlabel('x', 'FontName', 'Times New Roman', 'FontSize', 14);
ylabel('y', 'FontName', 'Times New Roman', 'FontSize', 14);
