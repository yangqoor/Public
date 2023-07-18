clear
%生成矩阵
%输入矩阵的阶数
n = input('input n=');
%Hilbert
for i = 1:n

    for j = 1:n
        a(i, j) = 1 / (i + j - 1);
    end

end

%生成n阶b
bc = ones(n, 1);
b = a * bc;
%输出n阶Hilbert矩阵
%%高斯法
%消去
d = [a b];
disp('--------------------------------------------')
disp('增广矩阵：'); disp(d)

for k = 1:(n - 1)

    for i1 = (k + 1):n
        C = d(i1, k) / d(k, k);

        for j0 = (k + 1):(n + 1)
            d(i1, j0) = d(i1, j0) - C * d(k, j0);
        end

    end

end

%回代
x = zeros(n, 1);
x(n, 1) = d(n, n + 1) / d(n, n);

for k1 = (n - 1):-1:1
    temp = d(k1, n + 1);

    for j1 = (k1 + 1):n
        temp = temp - d(k1, j1) * x(j1);
        x(k1, 1) = temp / d(k1, k1);
    end

end

disp('解 :'); disp(x)
