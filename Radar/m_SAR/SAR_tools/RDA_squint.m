%2016/12/1
%Liu Yakun

clc,clear,close all;

C = 3e8;%����
Rc = 20e3;%������б��
Theta = 22.8 / 180 * pi;%б�ӽ�
f0 = 5.3e9;%�״﹤��Ƶ��
lambda = C / f0;%�����źŲ���
V = 150;%�״�ƽ̨�ٶ�
Tr = 25e-6;%�������ʱ��
Kr = 0.25e12;%�����Ƶ��
Br = Kr * Tr;%�����źŴ���
Fr = 7.5e6;%�����������
fdop = 80;%�����մ���
Fa = 104;%��λ�������
alpha_Fr = Fr / Br;%�����������ϵ��
alpha_Fa = Fa / fdop;%��λ�������ϵ��

Nr = 256;
Na = 256;

Ka = -2 * V^2 * cos(Theta)^2 / lambda / Rc;
Tsar = fdop / abs(Ka);
fdoc = round(2 * V * sin(Theta) / lambda);
DY = C / Br / 2;


range_chirp = zeros(1,Nr);
tau = -Tr/2:1/Fr:Tr/2;
omega_range = -Fr/2:1/Tr:Fr/2;
range_chirp_temp = exp(1i*pi*Kr*tau.^2);
len_chirp_r = length(tau);

figure;
subplot(211);
plot(tau,real(range_chirp_temp),'r');
hold on;
plot(tau,imag(range_chirp_temp),'g');
xlabel('Time axis [sec]');
ylabel('Amplitude');
xlim([min(tau) max(tau)]);
title('Range Chirp');

subplot(212);
plot(omega_range,abs(fftshift(fft(range_chirp_temp))));
xlabel('Frequence [Hz]');
ylabel('Absolute');
xlim([min(omega_range) max(omega_range)]);
title('Spectrum of range chirp');

range_chirp(ceil((Nr - len_chirp_r)/2):ceil((Nr - len_chirp_r)/2) + len_chirp_r - 1) = range_chirp_temp;
RANGE_CHIRP = fft(range_chirp);
CON_RANGE_CHIRP = conj(RANGE_CHIRP);

azimuth_chirp = zeros(1,Na);
ta = -Tsar/2:1/Fa:Tsar/2;
omega_azimuth = -Fa/2:1/Tsar:Fa/2;

