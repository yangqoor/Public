dB=18:22;
PL_iter=[402 542 631 737 934];
PNL1_iter=[8 9 9 9 9];
PNL2_iter=[27 26 29 28 32];

PL_FFT=PL_iter*4;
PL_prod=PL_iter*3;

PNL_FFT=PNL1_iter*4+PNL2_iter*4;
PNL_prod=PNL1_iter*3+PNL2_iter*5;
hold on;
plot(dB,PL_FFT,'r');
plot(dB,PNL_FFT,'b');

plot(dB,PL_FFT,'r.');
plot(dB,PNL_FFT,'b.');

legend('PL的FFT运算量','PNL的FFT运算量');
hold off


figure;
hold on;
plot(dB,PL_prod,'r');
plot(dB,PNL_prod,'b');

plot(dB,PL_prod,'r.');
plot(dB,PNL_prod,'b.');

legend('PL乘法运算量','PNL乘法运算量');
hold off