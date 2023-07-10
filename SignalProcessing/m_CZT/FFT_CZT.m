clc
clear
close all
rng default

% x = randn(1013,1);
% y = czt(x);

fs = 1000;
d = designfilt('lowpassfir','FilterOrder',30,'CutoffFrequency',125, ...
    'DesignMethod','window','Window',@rectwin,'SampleRate',fs);
h = tf(d);

m = 1024;
y = fft(h,m);

f1 = 75;
f2 = 175;
w = exp(-1i*2*pi*(f2-f1)/(m*fs));
a = exp(1i*2*pi*f1/fs);
z = czt(h,m,w,a);

fn = (0:m-1)'/m;
fy = fs*fn;
fz = (f2-f1)*fn + f1;

plot(fy,abs(y),fz,abs(z))
% xlim([50 200])
legend('FFT','CZT')
xlabel('Frequency (Hz)')













