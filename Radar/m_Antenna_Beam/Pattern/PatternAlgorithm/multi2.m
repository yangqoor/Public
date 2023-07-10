% 对31元直线阵进行2个主瓣的综合
clear;

PHND = 90;
M = 31;
D = -30;
kp = 50;
kp1 = 50;
km = 3000;
z = 0.01;
DR = pi / 180;
K = 50;
L1 = 45;
R1 = 65;
L2 = 115;
R2 = 135;

for x = 1:180

    if (x >= L1 & x <= R1) | (x >= L2 & x <= R2)
        Pr(x) = 1;
        Pd(x) = 0;
    else
        Pr(x) = 0;
        Pd(x) = D;
    end

end

I = eye(M, M);

for n = 1:M

    for g = 1:180
        FF(n, g) = 2 * pi * (n - (M + 1) / 2) * 0.5 * cos(g * DR);
        Vs(n, g) = exp(-i * FF(n, g));
    end

end

Rs = zeros(M, M);

for n = 1:180
    A = Vs(:, n) * Vs(:, n)';
    Rs = A + Rs;
end

Rs = z * I + Rs;

Rd = zeros(M, 1);

for n = 1:180
    B = Pr(n) * Vs(:, n);
    Rd = B + Rd;
end

W = inv(Rs) * Rd;

for g = 1:180
    Py(g) = abs(Vs(:, g)' * W);
end

a = max(Py);

for g = 1:180
    Pyy = Py(g) / a;
    Py0(g) = 20 * log10(Pyy);
end

n = 1;

if Py(1) >= Py(2)
    t(n) = 1;
    n = n + 1;
end

for g = 2:(L1 - 1)

    if Py(g) >= Py(g - 1) & Py(g) >= Py(g + 1)
        t(n) = g;
        n = n + 1;
    end

end

for g = (L1 + 1):2:(R1 - 1)
    t(n) = g;
    n = n + 1;
end

for g = R1:L2

    if Py(g) >= Py(g - 1) & Py(g) >= Py(g + 1)
        t(n) = g;
        n = n + 1;
    end

end

for g = (L2 + 1):2:(R2 - 1)
    t(n) = g;
    n = n + 1;
end

for g = R2:179

    if Py(g) >= Py(g - 1) & Py(g) >= Py(g + 1)
        t(n) = g;
        n = n + 1;
    end

end

n = n - 1;

if Py(180) >= Py(179)
    n = n + 1;
    t(n) = 180;
end

I = eye(M, M);

for g = 1:180
    Py1(g) = Py0(g);
    Qy(g) = Py(g);
end

F = zeros(n, 1);
c = 1;

while c <= K % %condition % % %

    for g = 1:n

        if ((t(g) >= L1) & (t(g) <= R1)) | ((t(g) >= L2) & (t(g) <= R2))

            if abs(Py1(t(g)) - Pd(t(g))) <= 0.01 %main
                S = 0; %main
            else %main
                S = km * abs(Qy(t(g)) - a); %main
            end %main

            F(g, 1) = S; %main
        else

            F(g, 1) = max(kp * (Qy(t(g)) - a * 10^(Pd(t(g)) / 20)), 0);
        end

    end

    Rss = zeros(M, M);

    for g = 1:n
        A = F(g, 1) * (Vs(:, t(g)) * Vs(:, t(g))');
        Rss = A + Rss;
    end

    Rs = Rss + Rs;

    Rdd = zeros(M, 1);

    for g = 1:n
        B = F(g, 1) * Pr(t(g)) * Vs(:, t(g));
        Rdd = B + Rdd;
    end

    Rd = Rdd + Rd;
    W = inv(Rs) * Rd;

    for g = 1:180
        Qy(g) = abs(Vs(:, g)' * W);
    end

    a = max(Qy);

    for g = 1:180
        Py1(g) = 20 * log10(Qy(g) / a);
    end

    n = 1;

    if Qy(1) >= Qy(2)
        t(n) = 1;
        n = n + 1;
    end

    for g = 2:(L1 - 1)

        if Qy(g) >= Qy(g - 1) & Qy(g) >= Qy(g + 1)
            t(n) = g;
            n = n + 1;
        end

    end

    for g = (L1 + 1):2:(R1 - 1)
        t(n) = g;
        n = n + 1;
    end

    for g = R1:L2

        if Qy(g) >= Qy(g - 1) & Qy(g) >= Qy(g + 1)
            t(n) = g;
            n = n + 1;
        end

    end

    for g = (L2 + 1):2:(R2 - 1)
        t(n) = g;
        n = n + 1;
    end

    for g = R2:179

        if Qy(g) >= Qy(g - 1) & Qy(g) >= Qy(g + 1)
            t(n) = g;
            n = n + 1;
        end

    end

    n = n - 1;

    if Qy(180) >= Qy(179)
        n = n + 1;
        t(n) = 180;
    end

    c = c + 1;
end

%subplot(1,2,2)
g = 1:180;
plot(g, Py1);
axis([1 180 -60 5]);
grid on
