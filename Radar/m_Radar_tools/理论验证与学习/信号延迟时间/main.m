clear;clc;

T = 1e-5;
fs = 20e6;
sig = rt.exp_wave(T,3e6,fs);

delay = 0.3;                                                                  %延迟1个周期*delay
sig_f = fft(sig,512);
sig_out = ifft(sig_f.*exp(-1j.*2.*pi.*delay),512);
sig_out = sig_out(1:200);
%--------------------------------------------------------------------------
%   傅里叶变换延迟
%   s(t-t0) <-> S(f)exp(-1j*2*pi*t0*f)
%--------------------------------------------------------------------------
plot(real(sig));hold on
plot(real(sig_out));hold off;grid on
axis([0 200 -1.1 1.1])
