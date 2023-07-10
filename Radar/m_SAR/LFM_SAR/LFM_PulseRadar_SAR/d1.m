clear all;
close all;
clc;
%%����
fc = 10e9;              %�ز�Ƶ��
Tp = 10e-6;             %������
B = 10e6;               %�źŴ���
fs = 1e8;               %������
R = 3000;               %��ʼ��������
c = 3e8;                %����
PRT = 100e-6;           %�����ظ�����
CPI = 64;               %���������
v = 60;                 %Ŀ���˶��ٶ�

%%����
ta0 = 2 * R / c;        %��ʱ��ʱ��
Kr = B / Tp;            %���Ե�Ƶб��
t = 0:1 / fs:Tp + ta0;  %ʱ��Χ
M = length(t);
N = 100/10^(10/20);
s = zeros(64, M);

for k1 = 1:64
    ta = 2 * (R - (k1 - 1) * PRT * v) / c;
    s_back = 100 * rectpuls(t - ta - Tp / 2, Tp) .* exp(1i * pi * Kr * (t - Tp / 2 - ta).^2) .* exp(-1i * 2 * pi * fc * ta);
    noise = N / sqrt(2) * (randn(1, M) + 1i * randn(1, M));
    S_back = s_back + noise; %�������Ļز��ź�
    refer = rectpuls(t - Tp / 2, Tp) .* exp(1i * pi * Kr * (t - Tp / 2).^2);
    S3 = fft(S_back);
    S4 = fft(refer);
    S = S3 .* conj(S4);
    s1(k1, :) = ifft(S); %ѹ����Ļز��ź�
    s(k1, :) = s1(k1, :) / max(s1(k1, :)); %��һ��
    s(k1, :) = db(s(k1, :));
end

F_S = zeros(64, M);

for m = 1:M
    F_S(:, m) = fftshift(abs(fft(s1(:, m))));
end

%%���ֵ�� ���ٲ��
[maxrow, maxcol] = find(F_S == max(max(F_S))); %��������
range1 = maxcol * c / 2 / fs;
fd = (maxrow - 33) / CPI / PRT;
lamda = c / fc;
Vr = fd * lamda / 2;
%%���ķ� ���٣����
%���
index = maxcol - 5:maxcol + 5;
Amp = F_S(maxrow, index);
range2 = index * c / 2 / fs;
range0 = sum(range2 .* Amp) / sum(Amp);
%����
index = maxrow - 2:maxrow + 2;
Amp = F_S(index, maxcol).';
fd = (index - 33) / CPI / PRT;
Vlist = fd * lamda / 2;
V0 = sum(Vlist .* Amp) / sum(Amp);

%%��ʾ���
disp(['Ŀ��ز�������ʱ���ֵ����ľ���Ϊ:', num2str(range1), 'm']);
disp(['Ŀ��ز�������ʱ���ֵ������ٶ�Ϊ:', num2str(Vr), 'm/s']);
disp(['Ŀ��ز�������ʱ���ķ���ľ���Ϊ:', num2str(range0), 'm']);
disp(['Ŀ��ز�������ʱ���ķ�����ٶ�Ϊ:', num2str(V0), 'm/s']);
