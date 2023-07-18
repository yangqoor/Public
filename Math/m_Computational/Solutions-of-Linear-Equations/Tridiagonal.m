clear
clc
%    A=[2  -1  0    0
%       -1  3  -2   0
%       0  -2  4   -3
%       0  0   -3   5]
a = [0 -1 -2 -3]; c = [-1 -2 -3 0]; b = [2 3 4 5]; d = [6 1 -2 1];
n = length(b);
l(1) = b(1);
y(1) = d(1) / l(1);

for i = 2:n
    r(i - 1) = c(i - 1) / l(i - 1);
    l(i) = b(i) - a(i) * r(i - 1);
    y(i) = d(i) - a(i) * y(i - 1);
end

x(n) = y(n);

for j = (n - 1):-1:1
    x(j) = y(j) - r(j) * x(j + 1);
end

disp(x')
