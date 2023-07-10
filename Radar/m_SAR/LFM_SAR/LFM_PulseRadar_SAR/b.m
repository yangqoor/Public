clear;
close all;
clc;
%%����
fc = 10e9;               %�ز�Ƶ��
Tp = 10e-6;              %������
B = 10e6;                %�źŴ���
fs = 1e8;                %������
R = 3000;                %��ʼ��������
c = 3e8;                 %����
PRT = 100e-6;            %�����ظ�����
N = 64;                  %���������
v = 60;                  %Ŀ���˶��ٶ�

%%
ta0 = 2 * R / c;         %��ʱ��ʱ��
Kr = B / Tp;             %���Ե�Ƶб��
t = 0:1 / fs:Tp + ta0;   %ʱ��Χ
M = length(t);

for k = 1:64
    ta = 2 * (R - (k - 1) * PRT * v) / c;
    s_back = rectpuls(t - ta - Tp / 2, Tp) .* exp(1j * pi * Kr * (t - Tp / 2 - ta).^2) .* exp(-1j * 2 * pi * fc * ta);
    refer = rectpuls(t - Tp / 2, Tp) .* exp(1j * pi * Kr * (t - Tp / 2).^2);
    S1 = fft(s_back);
    S2 = fft(refer);
    S = S1 .* conj(S2);
    s1(k, :) = ifft(S); %ѹ����Ļز��ź�
    s(k, :) = s1(k, :) / max(s1(k, :)); %��һ��
    s(k, :) = db(s(k, :));
    [maxvalue, maxposition] = max(s(k, :)); %������ѹ�������ֵ�����ڵ���
end

for m = 1:M
    F_S(:, m) = fftshift(abs(fft(s1(:, m))));
end

[maxvalue, max_v] = max(F_S(:, maxposition)); %������
%����
fd = (max_v - 33) / PRT / N; %����Ƶ��
V_fd = fd * c / 2 / fc
%%���ٶȷ�Χ
fd_max = 1 / PRT / 2;
v_max = fd_max * c / 2 / fc
%%�⾫��
det_fd = 1 / PRT / 64;
det_v = det_fd * c / 2 / fc
figure
mesh(t * c / 2, linspace(-75, 75, 64), abs(F_S));
title('��ά���������ƽ��ͼ');
range_nonoise = maxposition * c / 2 / fs;
disp(['Ŀ��ز�������ʱ���ֵ����ľ���Ϊ:', num2str(range_nonoise), 'm']);
disp(['Ŀ��ز�������ʱ���ֵ������ٶ�Ϊ:', num2str(V_fd), 'm/s']);
