SLL = input('???SLL='); n = input('???n=');
R0 = 10^(-SLL / 20); A = (1 / pi) * acosh(R0); n1 = ceil(2 * A^2 + 1/2 + 1); sigma = n1 / sqrt(A^2 + (n1 - 1/2)^2);
x = ones(1, n);
lamda_g = 10.73;
d = lamda_g / 2;
L = (n) * d;

for i = 1:n1
    x(i) = sigma^2 * (A^2 + (i - 1/2)^2);
end

for j = 1:n1 - 1

    if j < n1

        for k = 1:n1
            B(j, k) = 1 - j^2 / x(k);
        end

        B1 = B(j, :);
        s(j) = (factorial(n1 - 1))^2 / (factorial(n1 - 1 + j) * factorial(n1 - 1 - j)) * prod(B1);
    else
        s(j) = 0;
    end

end

for l = 1:n
    zeta = (l - (n + 1) / 2) * d;
    p(l) = 2 * pi / L * zeta; sum = 0;

    for m = 1:n1 - 1
        sum = sum + s(m) * cos(m * p(l));
    end

    I(l) = 1 + 2 * sum;
end

if mod(n, 2) == 0
    I = I / I(n / 2);
else
    I = I / I((n + 1) / 2);
end
