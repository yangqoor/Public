%% Chirp Scaling�㷨
%��һ��
clear all;clc;
%%���������range:x domain
Tr    = 200;                                      %ʱ��200m
Br    = 1;                                        %����1
Kr    = Br / Tr;                                  %��Ƶб��
Fc    = 4;                                        %��Ƶ4
Nfast = 512;                                      %Ϊ�˿�������
Xc    = 1200; X0 = 150;                           %���������Χ
x     = Xc + linspace(-X0, X0, Nfast);            %x������:Xc-X0~Xc+X0
dx    = 2 * X0 / Nfast;                           %���岽��
kx    = linspace(-1 / dx / 2, 1 / dx / 2, Nfast); %kx������

%%��λ�����cross-range:y domain
Ta    = 300;                                      %ʱ��300m,�ϳɿ׾�����
Ba    = 1;                                        %����1(1/m)
Ka    = Fc / Xc;                                  %��Ƶб�� Ka=Ba/Ta=Fc/Xc
Nslow = 1024;                                     %Ϊ�˿�������
Y0    = 200;
y     = linspace(-Y0, Y0, Nslow);                 %y������:-Y0~Y0
dy    = 2 * Y0 / Nslow;
ky    = linspace(-1 / dy / 2, 1 / dy / 2, Nslow); %ky������

%%Ŀ�꼸�ι�ϵtarget geometry
%x����,y����,������ɢ��ϵ��
Ptar = [Xc, 0, 1 + 0j
    Xc + 50, -50, 1 + 0j
    Xc + 50, 50, 1 + 0j
    Xc - 50, -50, 1 + 0j
    Xc - 50, 50, 1 + 0j];

disp('Position of targets'); disp(Ptar)
%%����SAR���������Ļز�����
Srnm = zeros(Nfast, Nslow);
N = size(Ptar, 1); %Ŀ�����
h = waitbar(0, 'SAR�ز�����');

for i = 1:1:N
    xn = Ptar(i, 1); yn = Ptar(i, 2); sigma = Ptar(i, 3);                                     %��ȡÿ��Ŀ�����Ϣ
    X = x.' * ones(1, Nslow);                                                                 %����Ϊ����
    Y = ones(Nfast, 1) * y;                                                                   %����Ϊ����
    DX = sqrt(xn^2 + (Y - yn).^2);                                                            %�м����
    phase = pi * Kr * (X - DX).^2 - 2 * pi * Fc * DX;                                         %�ز���λ
    Srnm = Srnm + sigma * exp(j * phase) .* (abs(X - DX) < Tr / 2) .* (abs(Y - yn) < Ta / 2); %�ز��ۼ�
    waitbar(i / N)
end

close(h)
tic;
%%����׼��
phi0 = -x' * sqrt(Fc^2 - ky.^2);
phi1 = -Fc * x' * (1 ./ sqrt(Fc^2 - ky.^2));
phi2 = 1/2 * x' * (ky.^2 ./ (Fc^2 - ky.^2).^1.5);
Cs = ones(Nfast, 1) * (Fc ./ sqrt(Fc^2 - ky.^2) - 1);
Ks = 1 ./ (1 / Kr - 2 * phi2);

%%CSA:7��  ��ʼ
s_xky = fftshift(fft(fftshift(Srnm).')).';                                             %��λ��FFT(����1)
scs_xky = s_xky .* exp(j * pi * Cs .* Ks .* (x' * ones(1, Nslow) - Xc * (1 + Cs)).^2); %Chirp Scaling������2��
s1 = ifty(scs_xky);                                                                    %Ϊ��ʾ�洢����
scs_kxky = fftshift(fft(fftshift(scs_xky)));                                           %������FFT������3��
srmc_kxky = scs_kxky .* exp(j * pi * (kx.^2' * ones(1, Nslow)) ./ (1 + Cs) ./ Ks ...
    +j * 2 * pi * Xc * Cs .* (kx' * ones(1, Nslow)));                                  %����Ǩ��У��&������ƥ���˲�������4��
srmc_xky = fftshift(ifft(fftshift(srmc_kxky)));                                        %������IFFT������5��
f_xky = srmc_xky .* exp(-j * pi * Ks .* Cs .* (1 + Cs) .* ((x - Xc).^2' * ones(1, Nslow)) ...
    -j * 2 * pi * phi0);                                                               %������������λ��ƥ���˲�������6��
f_xy = fftshift(ifft(fftshift(f_xky).')).';                                            %��λ��IFFT������7��
%%CSA:7��  ����
toc;

%%Ϊ����ʾCSA�㷨��һ��RCMC����s1���о�����ѹ����ʾ
p0_x = exp(j * pi * Kr * (x - Xc).^2) .* (abs(x - Xc) < Tr / 2); %������LFM�ź�
p0_kx = fftshift(fft(fftshift(p0_x)));
p0_y = exp(-j * pi * Ka * y.^2) .* (abs(y) < Ta / 2); %��λ��LFM�ź�
p0_ky = fftshift(fft(fftshift(p0_y)));

s_kxy = fftshift(fft(fftshift(s1))); %������FFT
sxc_kxy = s_kxy .* (conj(p0_kx).' * ones(1, Nslow));
sxc_kxky = fftshift(fft(fftshift(sxc_kxy).')).'; %����ѹ�����2DƵ���ź�
sxc_xy = fftshift(ifft(fftshift(sxc_kxy))); %����ѹ������ź�
sxc_xky = fftshift(fft(fftshift(sxc_xy).')).'; %����ѹ���󣬾���-��������
%%�����ʾ
figure(1)
colormap(gray);
imagesc(255 - abs(Srnm));
xlabel('��λ��'), ylabel('������'),
title('����������ź�');

figure(2)
colormap(gray);
imagesc(255 - abs(sxc_xy));
xlabel('��λ��'), ylabel('������'),
title('Chirp Scaling�󡢾���������ѹ���������㶯һ��');

figure(3)
colormap(gray);
imagesc(255 - abs(srmc_xky));
xlabel('��λ��'), ylabel('������'),
title('���������㶯����ź�');

figure(4)
colormap(gray);
imagesc(255 - abs(f_xky));
xlabel('��λ��'), ylabel('������'),
title('��λУ������ź�');

figure(5)
colormap(gray);
imagesc(255 - abs(f_xy));
xlabel('��λ��'), ylabel('������'),
title('���ɵĵ�Ŀ��');
