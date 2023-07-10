% 对半波振子进行的方向图赋形算法
clear;

M = 30;
D = -30;
kp = 30;
km = 3000;
z = 0.01;
DR = pi / 180;
K = 100;

L = 80;
R = 80;

for x = 1:L - 1
    Pr(x) = 0;
end

for x = L:R
    Pr(x) = 1;
end

for x = R + 1:180
    Pr(x) = 0;
end

I = eye(M, M);

for n = 1:M

    for g = 1:180
        FF(n, g) = 2 * pi * (n - (M + 1) / 2) * 0.5 * cos(g * DR);
        ln = 0.25 + n * 0.25 / M;
        Vs(n, g) = (cos(2 * pi * ln * sin(g * DR)) - cos(2 * pi * ln)) / cos(g * DR) * exp(-i * FF(n, g));
    end

end

Rs = zeros(M, M);

for n = 1:180
    A = Vs(:, n) * Vs(:, n)';
    Rs = A + Rs;
end

Rs = z * I + Rs;

Rd = zeros(M, 1);

for n = L:R
    B = Pr(n) * Vs(:, n);
    Rd = B + Rd;
end

W = inv(Rs) * Rd;

for g = 1:180
    Py(g) = abs(Vs(:, g)' * W);
end

a = max(Py);

for g = 1:180
    Py0(g) = 20 * log10(Py(g) / a);
end

%subplot(1,2,1)
%g=1:180;
%plot(g,Py0);
%axis([1 180 -60 5]);

n = 1; % %find sidelobe peaks

if Py(1) >= Py(2)
    t(n) = 1;
    n = n + 1;
end

for g = 2:(L - 1)

    if Py(g) >= Py(g - 1) & Py(g) >= Py(g + 1)
        t(n) = g;
        n = n + 1;
    end

end

for g = L:1:R
    t(n) = g;
    n = n + 1;
end

for g = (R + 1):179

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

while c <= K % % %condition % % %

    for g = 1:n

        if (t(g) >= L) & (t(g) <= R)

            if abs(Qy(t(g)) - a * Pr(t(g))) <= 0.001 %main
                S = 0; %main
            else %main
                S = km * abs(Qy(t(g)) - a * Pr(t(g))); %main
            end %main

            F(g, 1) = S; %main
        else
            F(g, 1) = max(kp * (Qy(t(g)) - a * 10^(D / 20)), 0);
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

    for g = 2:(L - 1)

        if Qy(g) >= Qy(g - 1) & Qy(g) >= Qy(g + 1)
            t(n) = g;
            n = n + 1;
        end

    end

    for g = L:1:R
        t(n) = g;
        n = n + 1;
    end

    for g = (R + 1):179

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

Py1(90) = -100;
%subplot(1,2,2)
g = 1:180;
plot(g, Py1);
axis([1 180 -60 5]);
grid on
%%%%%%%%figure "41,D=-40"%%%%%%%%%%
