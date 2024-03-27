fs  = 100;                                 % �趨����Ƶ��
N   = 128;
n   = 0:N - 1;
t   = n / fs;
f0  = 10;                                  % �趨�����ź�Ƶ��
f1  = 6;
x   = sin(2 * pi * f0 * t) + sin(2 * pi * f1 * t);                % ���������ź�
figure(1);
subplot(211);
plot(t, x);                                % �������źŵ�ʱ����
xlabel('t');
ylabel('y');
title('�����ź�y=2*pi*10tʱ����');
grid;
% ����FFT�任����Ƶ��ͼ
y   = fft(x, N);                           % ����fft�任
mag = abs(y);                              % ���ֵ
f   = (0:length(y) - 1)' * fs / length(y); % ���ж�Ӧ��Ƶ��ת��
figure(1);
subplot(212);
plot(f, mag);                              % ��Ƶ��ͼ
axis([0, 100, 0, 80]);
xlabel('Frequency(Hz)');
ylabel('Amplitude');
title('�����ź�y=2*pi*10t��Ƶ��ͼN=128');
grid;
