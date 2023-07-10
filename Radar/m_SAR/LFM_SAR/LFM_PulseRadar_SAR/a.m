clc;
clear;
close all;
%%����
fc = 10e9;                      %�ز�Ƶ��
Tp = 10e-6;                     %������
B = 10e6;                       %�źŴ���
fs = 1e8;                       %������
R = 3000;                       %��ʼ��������
Kr = B / Tp;                    %���Ե�Ƶб��
c = 3e8;                        %����
%%�����ź�  �ο��ź�
t = 0:1 / fs:Tp + 2 * R / c;
N = length(t);
f = -fs / 2:fs / (N - 1):fs / 2;
refer = rectpuls(t - Tp / 2, Tp) .* exp(1i * pi * Kr * (t - Tp / 2).^2);
s = t * c / 2;
Refer = (fft(refer)); %�ο��źŵĸ���Ҷ�任
figure(1)
plot(s, real(refer));
grid;
title('�ο��źŵ�ʵ��');
figure(2)
plot(s, imag(refer));
grid;
title('�ο��źŵ��鲿');
figure(3)
%plot(f,abs(Refer));
plot(f, abs(fftshift(Refer)));
grid;
title('�ο��źŵ�Ƶ��');

%%�ز��ź�
tao = 2 * R / c;
s_back = rectpuls(t - tao - Tp / 2, Tp) .* exp(1i * pi * Kr * (t - tao - Tp / 2).^2) .* exp(-1i * 2 * pi * fc * tao);

%%����ѹ��

S_back = fft(s_back); %�ز��źŵĸ���Ҷ�任
S1 = abs(ifft(S_back .* conj(Refer)));
S = S1 / max(S1);
S = 20 * log10(S);

figure(4)
plot(s, real(s_back));
grid;
title('�ز��źŵ�ʵ��');
figure(5)
plot(s, imag(s_back));
grid;
title('�ز��źŵ��鲿');
figure(6)
plot(f, abs(fftshift(S_back)));
grid;
title('�ز��źŵ�Ƶ��');
figure(7)
plot(s, S);
title('��ѹ���ʱ����');
axis([2500 3500 -100 0]);
