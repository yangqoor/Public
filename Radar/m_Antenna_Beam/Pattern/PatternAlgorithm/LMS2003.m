% 一种改进的最小均方算法
clear;

M = 20; %input('the element number M=');
ddd = 0.5; %input('the distance ddd=');
D = -30; %input('the sidelobe level D=');
PHND = 90; %input('the mainlobe angle PHND=');
width = 30; %input('the mainlobe width =');
kp = 30; %input('the sidelobe iteration gain kp=');
km = 300; %input('the mainlobe iteration gain km=');
E = 1; %input('the errors E=');

w = width / 2;
DR = pi / 180;
I = eye(M, M);
z = 0.01;
L = PHND - w; %主瓣左端点
R = PHND + w; %主瓣右端点

for x = 1:180

    if x <= L | x >= R
        Pr(x) = 0; %参考方向图
        Pd(x) = D; %期望方向图
    else
        Pr(x) = 1;
        Pd(x) = 0;
    end

end

for n = 1:M

    for g = 1:180
        FF(n, g) = ddd * 2 * pi * (n - (M + 1) / 2) * cos(g * DR);
        Vs(n, g) = exp(-i * FF(n, g)); %导向矩阵
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

%subplot(1,2,1)
%g=1:180;
%plot(g,Py0);
%axis([1 180 -60 5]);
%grid on

n = 1;
r = 1;

if Py(1) >= Py(2)
    t(n) = 1; %旁瓣峰值点
    s(r, 1) = Py0(1); %旁瓣峰值点处的值
    n = n + 1;
    r = r + 1;
end

for g = 2:(L - 1)

    if Py(g) >= Py(g - 1) & Py(g) >= Py(g + 1)
        t(n) = g;
        s(r, 1) = Py0(g);
        n = n + 1;
        r = r + 1;
    end

end

for g = (L + 1):2:(R - 1)
    t(n) = g;
    n = n + 1;
end

for g = (R + 1):179

    if Py(g) >= Py(g - 1) & Py(g) >= Py(g + 1)
        t(n) = g;
        s(r, 1) = Py0(g);
        n = n + 1;
        r = r + 1;
    end

end

n = n - 1;
r = r - 1;

if Py(180) >= Py(179)
    n = n + 1;
    r = r + 1;
    t(n) = 180;
    s(r, 1) = Py0(180);
end

smax = max(s); %最大旁瓣

I = eye(M, M);

for g = 1:180
    Py1(g) = Py0(g);
    Qy(g) = Py(g);
end

F = zeros(n, 1);
c = 1; %c is the iteration frequency.

while smax > D + E

    for g = 1:n

        if (t(g) >= L) & (t(g) <= R)

            if abs(Py1(t(g)) - Pd(t(g))) <= 0.01
                S = 0;
            else
                S = km * abs(Qy(t(g)) - a);
            end

            F(g, 1) = S;
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
    r = 1;

    if Qy(1) >= Qy(2)
        t(n) = 1;
        s(r, 1) = Py1(n);
        n = n + 1;
        r = r + 1;
    end

    for g = 2:(L - 1)

        if Qy(g) >= Qy(g - 1) & Qy(g) >= Qy(g + 1)
            t(n) = g;
            s(r, 1) = Py1(g);
            n = n + 1;
            r = r + 1;
        end

    end

    for g = (L + 1):2:(R - 1)
        t(n) = g;
        n = n + 1;
    end

    for g = (R + 1):179

        if Qy(g) >= Qy(g - 1) & Qy(g) >= Qy(g + 1)
            t(n) = g;
            s(r, 1) = Py1(g);
            n = n + 1;
            r = r + 1;
        end

    end

    n = n - 1;
    r = r - 1;

    if Qy(180) >= Qy(179)
        n = n + 1;
        r = r + 1;
        t(n) = 180;
        s(r, 1) = Py1(180);
    end

    ss = s(1, 1);

    for g = 1:r
        smax = max(s(g, 1), ss);
        ss = smax;
    end

    c = c + 1;
end

%subplot(1,2,2)
g = 1:180;
plot(g, Py1);
axis([1 180 -60 5]);
grid on
%%%%%%%% Take M=21 for example.
%%%%%%%% km=300;
%%%%%%%% D=-30,kp=30;
%%%%%%%% D=-40,kp=100;
