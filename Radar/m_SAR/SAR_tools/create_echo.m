clear;
clc;
close all;
C = 3e8;                                          %����
fc = 5.3e9;                                       %��Ƶ
lambda = C / fc;                                  %����
Da = 3.75;                                        %���߿׾�
theta_bw = lambda / Da;                           %��λ�������
Rs = 20e3;                                        %����б��(��λ��m)
squint_angle = 0/180 * pi;                        %���߲���б�ӽǣ������������Ϊ0��
beta = 60/180 * pi;                               %���ӽ�60��
H = Rs * cos(beta);                               %�ػ��߶�
Yb = Rs * sin(beta);
V = 150;                                          %(����)�״���Ч�ٶ�(��λ��m/s)
Ta = Rs * theta_bw / V;                           %�ϳɿ׾�ʱ��
Tp = 10e-6;                                       %��������ʱ����λ��s��
B = 40e6;                                         %����
Fs = 60e6;                                        %��������ʣ���λ��Hz)
gama = B / Tp;                                    %�������Ƶ�ʣ���λ��Hz/s)
f_doppler = 2 * V / lambda;                       %�����մ���
PRF = 100;                                        %��λ�����ʣ���λ��Hz)
nrn = floor(1.2 * Tp * Fs / 2) * 2;               %�����������
nan = floor(1.2 * Ta * PRF / 2) * 2;              %����������Ҳ���Ƿ�λ����������
nrn = 1024;
nan = 200;
x = zeros(nrn, nan);                              %�����״�ز����ݾ���
tnrn = [-nrn / 2:nrn / 2 - 1]' / Fs + 2 * Rs / C; %������ʱ�����ݣ�����2Rs/c��Ϊ�˶�λ������...
                                            ... Ŀ��, ��c * t / 2 = Rs���� �������� ����2Rs / c Ŀ��
                                                  %tnrn=[-nrn/2:nrn/2-1]'/Fs;
Ryta = tnrn * C / 2;
tnan = [-nan / 2:nan / 2 - 1]' / PRF;             %��λ��ʱ������
PointN = 1;
sigman = 1;
x0 = 0; y0 = Yb; z0 = 0;
theta_Geo = theta_bw;
P = zeros(nrn, nan);

for n = 1:nan
    xT = V * tnan(n);
    yT = 0;
    zT = H;
    xn = x0 - xT; %�����λ�����״�λ�þ����x����ͶӰ
    yn = y0 - yT; %�����λ�����״�λ�þ����y����ͶӰ
    zn = z0 - zT;
    R = sqrt(xn^2 + yn^2 + zn^2); %�����λ�����״�λ�þ���Ĵ�С
    Ka = 2 * V^2 / lambda ./ Ryta;

    if abs(atan(xn / yn)) < theta_Geo / 2 %�жϵ�Ŀ���Ƿ����״�Ĳ����Ƿ�Χ��
        winr = ((tnrn - 2 * R / C) <= Tp / 2) & ((tnrn - 2 * R / C) >= -Tp / 2); %�ز��Ƿ��ڷ����źŰ�����       ��������������    1/4��3/4�ָ��в��У���
        echo = winr .* exp(j * pi * gama * (tnrn - 2 * R / C).^2) * exp(-j * 4 * pi * R / lambda);
        x(:, n) = x(:, n) + echo;
        P(:, n) = winr .* (-pi * Ka * tnan(n)^2 + pi * gama * (tnrn - 2 * R / C).^2);
        %P(:,n)=winr.*(-pi*Ka*tnan(n)^2+pi*gama*(tnrn-2*R/C).^2);
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%ԭʼ�ź�%%%%%%%%%%%%%%%%%%%%%%%%%
%P=(abs(x)>0).*P;
figure, subplot(221), imagesc(abs(x));
title('(a)�ز��źŷ���');
xlabel('��λ��'); %��һ�����ǻ�ԭʼ�ز����ݵ�ʱ�����ͼ
ylabel('������');
%subplot(222),contour(P,60);
title('(b)�ز��ź���λ');
xlabel('��λ��'); %��һ�����ǻ�ԭʼ�ز����ݵ�ʱ�����ͼ
ylabel('������');
save x;
%wr=(kaiser(nrn,2.5))';                    %��ƥ���˲�����Kaiser�����ɸ�����Ҫ��...
... Taylor / Chebyshev / Hanning / Hamming / Kaiser����
tp_nrn = floor(Tp * Fs / 2) * 2;
hrt = exp(-j * pi * gama * ([-tp_nrn / 2:tp_nrn / 2 - 1]' / Fs).^2);
serf = zeros(nrn, 1);
serf(nrn / 2 - tp_nrn / 2:nrn / 2 + tp_nrn / 2 - 1, 1) = hrt;
Hrf = fft(serf); %��ƥ���˲����任��Ƶ��

for n = 1:nan
    x(:, n) = fftshift(ifft(fft(x(:, n)) .* Hrf)); %��һ����ʵ�ֵ��Ǿ������ƥ���˲���������ѹ��
end

subplot(223), imagesc(abs(x));
title('����ѹ��');
xlabel('��λ��(������)'); %��һ�����ǻ�����ѹ����ķ���ͼ
ylabel('������(������)');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%��λѹ��
for m = 1:nrn
    % tempFlag = 0;
    % //if tempFlag==1
    %Ka=2*V^2/lambda/Ryta(m);        %�����յ���Ƶ��    ???????????   Ϊʲô����2ʽ,Ϊʲô���Ǹ���
    %else
    Ka = 2 * V^2 / lambda / Rs; %�����յ���Ƶ�� 2ʽ
    %end
    hat = (exp(-j * pi * Ka * tnan.^2))'; %???
    Haf = fft(hat);
    x(m, :) = fftshift(ifft(fft(x(m, :)) .* Haf));
end

subplot(224), imagesc(abs(x));
title('��λѹ��');
xlabel('��λ��(������)'); %��һ�����ǻ���λѹ����ķ���ͼ
ylabel('������(������)');
