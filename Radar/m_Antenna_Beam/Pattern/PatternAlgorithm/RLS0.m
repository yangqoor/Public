% 利用传统RLS法对均匀直线阵进行方向图综合
clear;

M = 10;
D = -20;
DR = pi / 180;
K = 1000;
forget = 1;

PHND = 90;

for g = 1:180

    for n = 1:M
        HH(n, g) = 2 * pi * (n - (M + 1) / 2) * 0.5 * cos(g * DR);
        H(n, g) = exp(i * HH(n, g));
    end

end

Hinv = inv(H * H');
W = Hinv * H(:, PHND);
Py = abs(H' * W);
m = max(Py);
Py0 = 20 * log10(Py / m);
subplot(1, 2, 1)
plot(Py0);
axis([1 180 -60 2]);
grid on
Qy = Py;

L = PHND + 1;
a = 0;

while a == 0
    L = L - 1;

    if Qy(L) < Qy(L - 1)
        a = 1;
    end

end

R = PHND - 1;
a = 0;

while a == 0
    R = R + 1;

    if Qy(R) < Qy(R + 1)
        a = 1;
    end

end

%%%%%%%%%%%iteration%%%%%%%%%
c = 0;
%while max(e)>m/6.5   %%condition%%%
while c < K

    for i = 1:180
        k(:, i) = Hinv * H(:, i) / (forget + H(:, i)' * Hinv * H(:, i));

        if i >= L && i <= R
            e(i) = Qy(i) - m * 10^(Py0(i) / 20);
        else
            e(i) = Qy(i) - m * 10^(D / 20);
        end

    end

    W = W + k * e';

    Qy = abs(H' * W);
    m = max(Qy);
    Py1 = 20 * log10(Qy / m);

    Hinv = (Hinv - k * H' * Hinv) / forget;

    c = c + 1;
end

subplot(1, 2, 2)
plot(Py1);
axis([1 180 -60 2]);
grid on
