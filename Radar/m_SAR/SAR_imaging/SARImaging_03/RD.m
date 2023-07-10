close all; clear; clc;
c      = 3e8;     %����
fc     = 5e9;     %�ز�Ƶ��
B      = 200e6;   %����
lambda = c / fc;  %����
Tp     = 1.5e-6;  %����
Kr     = B / Tp;  %��Ƶ��
fs     = 1.6 * B; %������

H      = 200;     %�ɻ��߶�
Ls     = 200;     %�ϳɿ׾�����
v      = 100;     %�ɻ��ٶ�
Lt     = Ls / v;  %�ϳɿ׾�ʱ��

% ��������[X0-Xc,X0+Xc; Y0-Yc,Y0+Yc]
% �Ժϳɿ׾�����Ϊԭ�㣬������Ϊx�ᣬ��λ��Ϊy��
Xc = 10000;
Yc = 0;
Xo = 100;
Yo = 100;

Rc   = sqrt(H^2 + Xc^2);                                            %���ľ���
Ka   = 2 * v^2 / (Rc * lambda);                                     %�����յ�Ƶ��
Bmax = Lt * Ka;                                                     %������������
fa   = ceil(3 * Bmax);                                              %�����ظ�Ƶ��

Rmin = sqrt(H^2 + (Xc - Xo)^2);                                     %�۲ⳡ����ɻ����������
Rmax = sqrt((Xc + Xo)^2 + H^2 + (Yc + Yo + Ls / 2)^2);              %��Զ����
rm   = Ls + 2 * Yo;                                                 %�״��߹�����·�̳���
tm   = 0:1 / fa:rm / v - 1 / fa;                                    %��ʱ�䣨�ϳɿ׾�ʱ��+��������ʱ�䣩
tk   = 2 * Rmin / c - Tp / 2:1 / fs:2 * Rmax / c - 1 / fs + Tp / 2; %��ʱ�䣨�������ڣ�

target = [Xc, Yc, 0;
    Xc + 80, Yc + 45, 0;
    Xc - 20, Yc - 20, 0];                             %Ŀ������
echo = zeros(length(tm), length(tk), length(target)); %�ز�
echo_all = zeros(length(tm), length(tk));
y = -v * (rm / v) / 2 + v * tm;                       %�ɻ�y������

for k = 1:size(target, 1)                                                                      %Ŀ����

    for i = 1:length(tm)                                                                       %��ʱ����
        radar = [0, y(i), H];                                                                  %�ɻ�����
        Rtm = sqrt(sum((target(k, :) - radar).^2));
        echo(i, :, k) = (abs(target(k, 2) - y(i)) / Xc < 0.01) * rectpuls(tk - 2 * Rtm / c, Tp) .* ...
            exp(1j * 2 * pi * fc * (tk - 2 * Rtm / c) + 1j * pi * Kr * (tk - 2 * Rtm / c).^2); %�ز�ģ��
        %ע���ϱ�Ϊʲô��tk-tr(i)-Tp/2��������tk-tr(i)
    end

    echo_all = echo(:, :, k) + echo_all;
end

r = ((tk * c / 2).^2 - H^2).^(1/2);

%% ������ƥ���˲�
for i = 1:size(echo_all, 1)
    echo_all(i, :) = echo_all(i, :) .* (exp(-1j * 2 * pi * fc * tk)); %�ز�ȥ��Ƶ
end

tt = 0:1 / fs:Tp - 1 / fs;
hk = exp(1j * pi * Kr * tt.^2);                                       %������ƥ���˲���
ECHO = zeros(size(echo_all));                                         %������ѹ��֮��

for i = 1:length(tm)
    ECHO(i, :) = ifft(fft(echo_all(i, :)) .* conj(fft(hk, length(tk))));
end

figure;
[R, Y] = meshgrid(r, y);
mesh(R, Y, abs(ECHO)); view(0, 90); xlim([9900 10100]);
xlabel('������');
% ylabel('�ϳɿ׾� (��ʱ��), meters');
title('����ѹ����');

ha = exp(-1j * pi * 2 * (v^2) / (lambda * Rc) * (0:1 / fa:Lt - 1 / fa).^2); %��λ��ƥ���˲���

for k = 1:length(tk)
    ECHO(:, k) = fftshift(fft(ECHO(:, k)));
end

%% �����㶯����
N = 6;                                       %��ֵ�˳���Ϊ6
ECHO_RCMC = zeros(size(ECHO));
h = waitbar(0, 'Sinc��ֵ��......');          %����һ��������

for k = 1:length(tm)
    f = linspace(-fa / 2, fa / 2, length(tm));
    deltaR = (lambda * f(k) / v)^2 * Rc / 8; %ע�����f���������ĸ�f
    DU = 2 * deltaR * fs / c;
    du = DU - floor(DU);
    %     kernel_norm = sum(sinc(du-(-N/2:N/2-1)));
    for n = N / 2 + 1:length(tk) %��ʱ��

        for m = -N / 2:N / 2 - 1

            if n + floor(DU) + m > length(tk)
                ECHO_RCMC(k, n) = ECHO_RCMC(k, n) + ECHO(k, length(tk)) * sinc(DU - m);
            else
                ECHO_RCMC(k, n) = ECHO_RCMC(k, n) + ECHO(k, n + floor(DU) + m) * sinc(du - m);
            end

        end

    end

    waitbar(k / length(tm));
end

close(h); %�رս�����

figure;
[R, Y] = meshgrid(r, y);
mesh(R, Y, abs(ifft(ECHO_RCMC))); view(0, 90); xlim([9900 10100]);
title('�����㶯����')
xlabel('������');

%% ��λ��ƥ���˲�
for k = 1:length(tk)
    ECHO(:, k) = abs(ifft(fft(ha, length(tm))' .* fftshift(ECHO_RCMC(:, k)))); %��λ��ѹ����
end

figure;
mesh(r, y, ECHO);
view(0, 90)
xlim([9900 10100]);
xlabel('������');
ylabel('��λ��');
zlabel('����'); title('����ѹ�����');
