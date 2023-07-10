% LFM 信号
clear

Tu = 2e-6;
B = 150e6;
fs = 180e6;
kr = B / Tu;
fc = 10.e9;
c = 3.e8;
lamd = c / fc;
Nr = 1024;
Tr = Nr / fs;

V = 100.;
R0 = 5000;
PRF = 600.;
Na = 2048;
Ta = Na / PRF;
ta = linspace(-Ta / 2, Ta / 2, Na);

beta = 1/180 .* pi;
xm1 = 0.;
ym1 = 0.;

xm2 = 100.;
ym2 = 0.;

xr = V * ta;
yr = -R0;

tr = 2 * R0 / c + linspace(-Tr / 2, Tr / 2, Nr);

foriginal = exp(1i * pi * kr * (tr - 2 * R0 / c).^2) .* (abs(tr - 2 * R0 / c) < Tu / 2);
h = conj(foriginal);
H = fft(fftshift(h));
%original=exp(j*pi*kr*(tr-2*R0/c).^2).*(abs(tr-2*R0/c)<Tu/2);
data = zeros(Nr, Na);

for k = 1:Na
    a = atan(xr(k) / 5000);

    if (abs(a) < (beta / 2))

        Rt = sqrt((xr(k) - xm1)^2 + (yr - ym1)^2);
        record = exp(1i * pi * kr * (tr - 2 * Rt / c).^2) .* (abs(tr - 2 * Rt / c) < Tu / 2) * exp(-1i * 4 * pi / lamd * Rt);
    else 
        record = 0;
    end

    ss = ifft(fft(record) .* H);
    data(:, k) = transpose(ss);
end

imagesc(abs(data));
