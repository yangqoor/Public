% 用music算法进行的DOA估计
clear;

Pd = 1000;
Fd = 1;
Fs = 4 * Fd;
R = 0.5;
Delay = 5;
No = 1;
m = 4;
x1 = randint(Pd, 1, m);
x2 = randint(Pd, 1, m);
x3 = randint(Pd, 1, m);
%y1=modmap(x1,Fd,Fs,'qask',m);
%y2=modmap(x2,Fd,Fs,'qask',m);
%y3=modmap(x3,Fd,Fs,'qask',m);
%[rcv_a1,ti]=rcosflt(y1,Fd,Fs,'fir/sqrt/Fs',R,Delay);
%[rcv_a2,ti]=rcosflt(y2,Fd,Fs,'fir/sqrt/Fs',R,Delay);
%[rcv_a3,ti]=rcosflt(y3,Fd,Fs,'fir/sqrt/Fs',R,Delay);
s1 = dmodce(x1, Fd, Fs, 'ask', m);
s2 = dmodce(x2, Fd, Fs, 'ask', m);
s3 = dmodce(x3, Fd, Fs, 'ask', m);
%s1=demodmap(rcv_a1,Fd,Fs,'qam',m);
%s2=demodmap(rcv_a2,Fd,Fs,'qam',m);
%s3=demodmap(rcv_a3,Fd,Fs,'qam',m);
%s1=amodce(rcv_a1,10,'qam');
%s2=amodce(rcv_a2,10,'qam');
%s3=amodce(rcv_a3,10,'qam');

i = sqrt(-1);
j = i;
M = 8;
p = 3;
angle1 = 30;
angle2 = 35;
angle3 = 141;
th = [angle1; angle2; angle3];
nn = 1024;
SN1 = 10; SN2 = 10; SN3 = 5; % % %dB
sn = [SN1; SN2; SN3];
degrad = pi / 180;

u = 1:nn;
S = [s1(u).'; s2(u).'; s3(u).'];
nr = randn(M, nn);
ni = randn(M, nn);
U = nr + j * ni;
Ps = S * S.' / nn;
ps = diag(Ps);
refp = 2 * 10.^(sn / 10);
tmp = sqrt(refp ./ ps);
S2 = diag(tmp) * S;

tmp = -i * pi * cos(th' * degrad);

tmp2 = [0:M - 1]';
a2 = tmp2 * tmp;
A = exp(a2);
X = A * S2 + U;
Rxx = X * X' / nn;
[U, S, V] = svd(Rxx); % % %特征分解
Vs = U(:, 1:p);
Vu = U(:, p + 1:M);

th2 = [0:180]';
tmp = -i * pi * cos(th2' * degrad);
tmp2 = [0:M - 1]';
a2 = tmp2 * tmp;
A2 = exp(a2);
num = diag(A2' * A2);
Ena = Vu' * A2;
den = diag(Ena' * Ena);
doa = num ./ den;

semilogy(th2, doa);
title('MUSIC Spectrum');
xlabel('Angle(deg)');
ylabel('Spectrum');
axis([0 180 0.1 1e7]);
grid;
