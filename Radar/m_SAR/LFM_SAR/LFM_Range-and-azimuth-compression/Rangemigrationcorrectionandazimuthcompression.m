% 距离偏移校正和方位压缩
clear all;
clc;
fc = 10.e9;
c = 3.e8;
lamd = c / fc;

Tp = 5.e-7;
Br = 500.e6;
kr = Br / Tp;
fs = 600.e6;
Nr = 1024;
Tr = Nr / fs;

V = 120.;
R0 = 5000.;
PRF = 600.;
Na = 4096;
Ta = Na / PRF;
ta = linspace(-Ta / 2, Ta / 2, Na);

Beta = 4 * pi / 180;

xm = 0;
ym = 0;

xn = 50.;
yn = 0;

xk = 50.;
yk = 50.;

xr = V * ta;
yr = -R0;

tr = 2 * R0 / c + linspace(-Tr / 2, Tr / 2, Nr);
tt = linspace(-Tr / 2, Tr / 2, Nr);
a = exp(j * pi * kr * tt.^2) .* (abs(tt) < Tp / 2);
data = zeros(Nr, Na);

for k = 1:Na

    Alpham = abs(xm - xr(k)) / abs(ym - yr);

    if abs(Alpham) < (tan(Beta / 2))
        Rt1 = sqrt((xr(k) - xm)^2 + (yr - ym)^2);
        record1 = exp(j * pi * kr * (tr - 2 * Rt1 / c).^2) .* (abs(tr - 2 * Rt1 / c) < Tp / 2) * exp(-j * 4 * pi / lamd * Rt1);
    else
        record1 = 0;
    end

    Alphan = abs(xn - xr(k)) / abs(yn - yr);

    if abs(Alphan) < (tan(Beta / 2))
        Rt2 = sqrt((xr(k) - xn)^2 + (yr - yn)^2);
        record2 = exp(j * pi * kr * (tr - 2 * Rt2 / c).^2) .* (abs(tr - 2 * Rt2 / c) < Tp / 2) * exp(-j * 4 * pi / lamd * Rt2);
    else
        record2 = 0;
    end

    Alphak = abs(xk - xr(k)) / abs(yk - yr);

    if abs(Alphak) < (tan(Beta / 2))
        Rt3 = sqrt((xr(k) - xk)^2 + (yr - yk)^2);
        record3 = exp(j * pi * kr * (tr - 2 * Rt3 / c).^2) .* (abs(tr - 2 * Rt3 / c) < Tp / 2) * exp(-j * 4 * pi / lamd * Rt3);
    else
        record3 = 0;
    end

    record = record1 + record2 + record3;
    Hf = fft(fliplr(conj(fftshift(a))));
    record = ifft(fft(record) .* Hf);
    data(:, k) = transpose(record);
end

fa = linspace(-PRF / 2, PRF / 2, Na);
fa = fftshift(fa);

for l = 1:Nr
    data(l, :) = fft(data(l, :));
end

f = linspace(-fs / 2, fs / 2, Nr);
f = fftshift(f)
DeltaR = lamd^2 * R0 * fa.^2 / V^2/8;

for l = 1:Na data(:, l) = ifft(fft(data(:, l)) .* transpose(exp(j * 2 * pi * f * DeltaR(l) * 2 / c)));
end

for l = 1:Nr
    ka = 2 * V.^2 / lamd / (R0 - Nr / 2 * c / 2 / fs + l * c / 2 / fs);
    Hfa = exp(-j * pi * fa.^2 / ka);
    data(l, :) = ifft(data(l, :) .* Hfa);
end

imagesc(abs(data));
