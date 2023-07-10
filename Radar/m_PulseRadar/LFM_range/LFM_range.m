% LFMһά������
clc
clear all
close all

%%�������Ե�Ƶ�ź�
c = 3e8;             %��Ų������ٶ�
fz = 16.5e9;         %�����ź���Ƶ
bz = c / fz;         %�����źŲ���
Pt = 5;              %�����źŹ���(37dBm)
G = 1000;            %�������棨30dB)
T = 1e-3;            %���Ե�Ƶ������
Bz = 100e6;          %��Ƶ����
Kz = Bz / T;         %��Ƶб��
Fs = 2 * Bz;         %����Ƶ��
Ts = 1 / Fs;
N = T / Ts;          %��������
t = linspace(-T / 2, T / 2, N);
Sta = exp(j * pi * Kz * t.^2);
St = sqrt(Pt) * Sta; %������������Ե�Ƶ�ź�
subplot(2, 1, 1)
plot(t * 1e3, real(St));
xlabel('ʱ��/ms');
title('�������Ե�Ƶ�ź�ʵ��');
grid on;
axis tight;
subplot(2, 1, 2)
freq = linspace(-Fs / 2, Fs / 2, N);
plot(freq * 1e-6, fftshift(abs(fft(St))))
xlabel('Ƶ��/MHz');
title('�������Ե�Ƶ�ź�Ƶ��');

grid on;
axis tight;
%-----------------------------------------------------------------------
%-----------------------------------------------------------------------
R0 = 6e4;
nc = 59850;
Nc = 300;
K = 120; %һά�������������Ӧ��ͬ�Ƕȣ�
%%����1��Ŀ��ģ�����ݿ�
x = 1:30;
y = exp(- (x - 15).^2/50);
M1 = 50; %ɢ������
rcs1 = 10^4 * [0.8 * y(16:30) y 0.8 * y y 0.8 * y(1:15)];

for i = 1:K
    mu1(i) = rcs1(i) / M1;
    ci1 = 40; %RCS��׼��
end

Num = 300;
loc = randn(1, Num);
loca = find(loc >- 1 & loc < 1, M1, 'first');
locat = loc(loca);
x1 = 80 * locat;
y1 = 8 * locat;

for j = 1:K
    theta = (j - 1) * 2 * pi / K;
    Sr = zeros(1, N);
    R = x1 * cos(theta) + y1 * sin(theta);
    R = R0 + R; %ɢ������
    deta1 = abs(normrnd(mu1(j), ci1, 1, M1));

    for i = 1:M1
        tao(i) = 2 * R(i) / c; %ɢ�����ʱ
        temp = zeros(1, 2 * N);
        k = ceil(tao(i) / Ts);
        Pr(i) = Pt * (G^2) * (bz^2) * deta1(i) / ((4 * pi)^3 * (R(i)^4)); %����ɢ���ز�����
        Ar(i) = sqrt(Pr(i)); %����ɢ���ز��źŷ���
        temp(k:k + N - 1) = Ar(i) .* Sta;
        temp1 = temp(1:N);
        Sr = temp1 + Sr;
    end

    S1(j, :) = fftshift(abs(fft(Sr .* conj(St))));
    Sig1_f(j, :) = S1(j, nc:nc + Nc - 1);
    Sig1_f(j, :) = Sig1_f(j, :) ./ norm(Sig1_f(j, :));

    Si1(j, :) = fftshift(fft(Sr .* conj(St)));
    Sig1_f1(j, :) = Si1(j, nc:nc + Nc - 1);
    Sig1_f1(j, :) = Sig1_f1(j, :) ./ norm(Sig1_f1(j, :));
    %     f=linspace(-Fs/2,Fs/2,N);
    %     r=f.*(c*T/Fs);                                                    %����ת���Ĺ�ʽ
    %     figure(j+1);
    %     plot(r*1e-3,Sig1_f(j,:))
    %     title('1��Ŀ�������');
    %     xlabel('����/km');
    %     ylabel('��һ������');
    %     grid on;
end

Sig1_f = Sig1_f';
file1 = 'Sig1_f.mat';
file11 = 'Sig1_f1.mat';
save(file1, 'Sig1_f');
save(file11, 'Sig1_f1');
%%-------------------------------------------------------------
% %%����2��Ŀ��ģ�����ݿ�
% x=1:30;
% y=exp(-(x-15).^2/100);
% M2=100;
% rcs2=5*10^3*[0.8*y(16:30) y 0.8*y y 0.8*y(1:15)];
% for i=1:K
%     mu2(i)=rcs2(i)/M2;
%     ci2=40;                                                       %RCS��׼��
% end                                                      %ɢ������                                                       %RCS��׼��
% Num=400;
% loc=randn(1,Num);
% loca=find(loc>-1&loc<1,M2,'first');
% locat=loc(loca);
% x2=160*locat;
% y2=30*locat;                                                        %һά�������������Ӧ��ͬ�Ƕȣ�
% for j=1:K
%     theta=(j-1)*2*pi/K;
%     Sr=zeros(1,N);
%     R=x2*cos(theta)+y2*sin(theta);
%     R=R0+R;                                   %ɢ������
%     deta2=abs(normrnd(mu2(j),ci2,1,M2));
%     for i=1:M2
%         tao(i)=2*R(i)/c;                                        %ɢ�����ʱ
%         temp=zeros(1,2*N);
%         k=ceil(tao(i)/Ts);
%         Pr(i)=Pt*(G^2)*(bz^2)*deta2(i)/((4*pi)^3*(R(i)^4));              %����ɢ���ز�����
%         Ar(i)=sqrt(Pr(i));                                               %����ɢ���ز��źŷ���
%         temp(k:k+N-1)=Ar(i).*Sta;
%         temp1=temp(1:N);
%         Sr=temp1+Sr;
%     end
%     S2(j,:)=fftshift(abs(fft(Sr.*conj(St))));
%     Sig2_f(j,:)=S2(j,nc:nc+Nc-1);
%     Sig2_f(j,:)=Sig2_f(j,:)./norm(Sig2_f(j,:));
%
%     Si2(j,:)=fftshift(fft(Sr.*conj(St)));
%     Sig2_f1(j,:)=Si2(j,nc:nc+Nc-1);
%     Sig2_f1(j,:)=Sig2_f1(j,:)./norm(Sig2_f1(j,:));
%     %f=linspace(0,Fs,N);
%     %r=f.*(c*T/Fs);                                                    %����ת���Ĺ�ʽ
%     %figure(j+13);
%     %plot(r*1e-3,Sig2_f(j,:))
%     %title('2��Ŀ�������');
%     %xlabel('����/km');
%     %ylabel('��һ������');
%     %grid on;
% end
% Sig2_f=Sig2_f';
% file2='Sig2_f.mat';
% file21='Sig2_f1.mat';
% save(file2,'Sig2_f');
% save(file21,'Sig2_f1');
% %%-----------------------------------------------------------
% %%����3��Ŀ��ģ�����ݿ�
% x=1:30;
% y=exp(-(x-15).^2/200);
% M3=10;                                                        %ɢ������
% rcs3=500*[0.8*y(16:30) y 0.8*y y 0.8*y(1:15)];
% for i=1:K
%     mu3(i)=rcs3(i)/M3;
%     ci3=40;                                                       %RCS��׼��
% end
% Num=100;
% loc=randn(1,Num);
% loca=find(loc>-1&loc<1,M3,'first');
% locat=loc(loca);
% x3=14*locat;
% y3=2*locat;                                                        %һά�������������Ӧ��ͬ�Ƕȣ�
% for j=1:K
%     theta=(j-1)*2*pi/K;
%     Sr=zeros(1,N);
%     R=x3*cos(theta)+y3*sin(theta);
%     R=R0+R;                                   %ɢ������
%     deta3=abs(normrnd(mu3(j),ci3,1,M3));
%     for i=1:M3
%         tao(i)=2*R(i)/c;                                        %ɢ�����ʱ
%         temp=zeros(1,2*N);
%         k=ceil(tao(i)/Ts);
%         Pr(i)=Pt*(G^2)*(bz^2)*deta3(i)/((4*pi)^3*(R(i)^4));              %����ɢ���ز�����
%         Ar(i)=sqrt(Pr(i));                                               %����ɢ���ز��źŷ���
%         temp(k:k+N-1)=Ar(i).*Sta;
%         temp1=temp(1:N);
%         Sr=temp1+Sr;
%     end
%     S3(j,:)=fftshift(abs(fft(Sr.*conj(St))));
%     Sig3_f(j,:)=S3(j,nc:nc+Nc-1);
%     Sig3_f(j,:)=Sig3_f(j,:)./norm(Sig3_f(j,:));
%
%     Si3(j,:)=fftshift(fft(Sr.*conj(St)));
%     Sig3_f1(j,:)=Si3(j,nc:nc+Nc-1);
%     Sig3_f1(j,:)=Sig3_f1(j,:)./norm(Sig3_f1(j,:));
%     %f=linspace(0,Fs,N);
%     %r=f.*(c*T/Fs);                                                    %����ת���Ĺ�ʽ
%     %figure(j+25);
%     %plot(r*1e-3,Sig3_f(j,:))
%     %title('3��Ŀ�������');
%     %xlabel('����/km');
%     %ylabel('��һ������');
%     %grid on;
% end
% Sig3_f=Sig3_f';
% file3='Sig3_f.mat';
% file31='Sig3_f1.mat';
% save(file3,'Sig3_f');
% save(file31,'Sig3_f1');
