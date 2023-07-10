% 一种改进的RLS法
clear;

M = 4;
D = -20;
DR = pi / 180;
K = 1000;
forget = 0.05;

L = 60;
R = 100;

for x = 1:180

    if x >= L & x <= R
        Pr(x) = 1;
        Pd(x) = 0;
    else
        Pr(x) = 0;
        Pd(x) = D;
    end

end

Pr = Pr';
Pd = Pd';

for g = 1:180

    for n = 1:M
        HH(g, n) = 2 * pi * (n - (M + 1) / 2) * 0.5 * cos(g * DR);
        H(g, n) = exp(-i * HH(g, n));
    end

end

Hinv = inv(H' * H);
W = Hinv * (H' * Pr);
Py = abs(H * W);
m = max(Py);
Py0 = 20 * log10(Py / m);

subplot(1, 2, 1)
plot(Py0);
axis([1 180 -60 5]);
grid on

Qy = Py;
%%%%%%%%%%%iteration%%%%%%%%%
c = 1;

while c <= K % %condition % % %

    n = 1;

    if Qy(1) >= Qy(2)
        t(n) = 1; %旁瓣峰值点
        n = n + 1;
    end

    for g = 2:L - 1

        if Qy(g) >= Qy(g - 1) & Qy(g) >= Qy(g + 1)
            t(n) = g;
            n = n + 1;
        end

    end

    for g = L:2:R

        if Qy(g) >= Qy(g - 1) & Qy(g) >= Qy(g + 1)
            t(n) = g;
            n = n + 1;
        end

    end

    for g = R + 1:179

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

    %%%%%%%%%%%%%寻找最差值%%%%%%%%%%%
    wor = 0; a = 0;

    for i = 1:n

        if t(i) <= R && t(i) >= L
            a = 0; %abs(m-Qy(t(i)));
        else
            a = abs(Qy(t(i)) - m * 10^(D / 20));
        end

        if a > wor
            wor = a;
            worst = t(i);
        end

    end

    mside(c) = 20 * log10(Qy(worst) / m);

    F = H(worst, :) * Hinv;
    u = H(worst, :) * F';
    G = F' / (forget + u);
    W = W + wor * G; % % % % % % % % %  new weight vector % % % % % % % % %
    Hinv = Hinv - G * F;
    Qy = abs(H * W);
    m = max(Qy);
    Py1 = 20 * log10(Qy / m);

    c = c + 1;
end

c = c - 1;

subplot(1, 2, 2)
plot(Py1);
axis([1 180 -60 5]);
grid on

figure
plot(mside);
axis([1 K -30 -12]);
