% LFM一维距离像
clc
clear all
close all

%%产生线性调频信号
c = 3e8;             %电磁波传播速度
fz = 16.5e9;         %发射信号载频
bz = c / fz;         %发射信号波长
Pt = 5;              %发射信号功率(37dBm)
G = 1000;            %天线增益（30dB)
T = 1e-3;            %线性调频脉冲宽度
Bz = 100e6;          %调频带宽
Kz = Bz / T;         %调频斜率
Fs = 2 * Bz;         %采样频率
Ts = 1 / Fs;
N = T / Ts;          %采样点数
t = linspace(-T / 2, T / 2, N);
Sta = exp(j * pi * Kz * t.^2);
St = sqrt(Pt) * Sta; %产生发射的线性调频信号
subplot(2, 1, 1)
plot(t * 1e3, real(St));
xlabel('时间/ms');
title('发射线性调频信号实部');
grid on;
axis tight;
subplot(2, 1, 2)
freq = linspace(-Fs / 2, Fs / 2, N);
plot(freq * 1e-6, fftshift(abs(fft(St))))
xlabel('频率/MHz');
title('发射线性调频信号频谱');

grid on;
axis tight;
%-----------------------------------------------------------------------
%-----------------------------------------------------------------------
R0 = 6e4;
nc = 59850;
Nc = 300;
K = 120; %一维距离像个数（对应不同角度）
%%产生1类目标模板数据库
x = 1:30;
y = exp(- (x - 15).^2/50);
M1 = 50; %散射点个数
rcs1 = 10^4 * [0.8 * y(16:30) y 0.8 * y y 0.8 * y(1:15)];

for i = 1:K
    mu1(i) = rcs1(i) / M1;
    ci1 = 40; %RCS标准差
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
    R = R0 + R; %散射点距离
    deta1 = abs(normrnd(mu1(j), ci1, 1, M1));

    for i = 1:M1
        tao(i) = 2 * R(i) / c; %散射点延时
        temp = zeros(1, 2 * N);
        k = ceil(tao(i) / Ts);
        Pr(i) = Pt * (G^2) * (bz^2) * deta1(i) / ((4 * pi)^3 * (R(i)^4)); %单个散射点回波功率
        Ar(i) = sqrt(Pr(i)); %单个散射点回波信号幅度
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
    %     r=f.*(c*T/Fs);                                                    %距离转换的公式
    %     figure(j+1);
    %     plot(r*1e-3,Sig1_f(j,:))
    %     title('1类目标距离像');
    %     xlabel('距离/km');
    %     ylabel('归一化幅度');
    %     grid on;
end

Sig1_f = Sig1_f';
file1 = 'Sig1_f.mat';
file11 = 'Sig1_f1.mat';
save(file1, 'Sig1_f');
save(file11, 'Sig1_f1');
%%-------------------------------------------------------------
% %%产生2类目标模板数据库
% x=1:30;
% y=exp(-(x-15).^2/100);
% M2=100;
% rcs2=5*10^3*[0.8*y(16:30) y 0.8*y y 0.8*y(1:15)];
% for i=1:K
%     mu2(i)=rcs2(i)/M2;
%     ci2=40;                                                       %RCS标准差
% end                                                      %散射点个数                                                       %RCS标准差
% Num=400;
% loc=randn(1,Num);
% loca=find(loc>-1&loc<1,M2,'first');
% locat=loc(loca);
% x2=160*locat;
% y2=30*locat;                                                        %一维距离像个数（对应不同角度）
% for j=1:K
%     theta=(j-1)*2*pi/K;
%     Sr=zeros(1,N);
%     R=x2*cos(theta)+y2*sin(theta);
%     R=R0+R;                                   %散射点距离
%     deta2=abs(normrnd(mu2(j),ci2,1,M2));
%     for i=1:M2
%         tao(i)=2*R(i)/c;                                        %散射点延时
%         temp=zeros(1,2*N);
%         k=ceil(tao(i)/Ts);
%         Pr(i)=Pt*(G^2)*(bz^2)*deta2(i)/((4*pi)^3*(R(i)^4));              %单个散射点回波功率
%         Ar(i)=sqrt(Pr(i));                                               %单个散射点回波信号幅度
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
%     %r=f.*(c*T/Fs);                                                    %距离转换的公式
%     %figure(j+13);
%     %plot(r*1e-3,Sig2_f(j,:))
%     %title('2类目标距离像');
%     %xlabel('距离/km');
%     %ylabel('归一化幅度');
%     %grid on;
% end
% Sig2_f=Sig2_f';
% file2='Sig2_f.mat';
% file21='Sig2_f1.mat';
% save(file2,'Sig2_f');
% save(file21,'Sig2_f1');
% %%-----------------------------------------------------------
% %%产生3类目标模板数据库
% x=1:30;
% y=exp(-(x-15).^2/200);
% M3=10;                                                        %散射点个数
% rcs3=500*[0.8*y(16:30) y 0.8*y y 0.8*y(1:15)];
% for i=1:K
%     mu3(i)=rcs3(i)/M3;
%     ci3=40;                                                       %RCS标准差
% end
% Num=100;
% loc=randn(1,Num);
% loca=find(loc>-1&loc<1,M3,'first');
% locat=loc(loca);
% x3=14*locat;
% y3=2*locat;                                                        %一维距离像个数（对应不同角度）
% for j=1:K
%     theta=(j-1)*2*pi/K;
%     Sr=zeros(1,N);
%     R=x3*cos(theta)+y3*sin(theta);
%     R=R0+R;                                   %散射点距离
%     deta3=abs(normrnd(mu3(j),ci3,1,M3));
%     for i=1:M3
%         tao(i)=2*R(i)/c;                                        %散射点延时
%         temp=zeros(1,2*N);
%         k=ceil(tao(i)/Ts);
%         Pr(i)=Pt*(G^2)*(bz^2)*deta3(i)/((4*pi)^3*(R(i)^4));              %单个散射点回波功率
%         Ar(i)=sqrt(Pr(i));                                               %单个散射点回波信号幅度
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
%     %r=f.*(c*T/Fs);                                                    %距离转换的公式
%     %figure(j+25);
%     %plot(r*1e-3,Sig3_f(j,:))
%     %title('3类目标距离像');
%     %xlabel('距离/km');
%     %ylabel('归一化幅度');
%     %grid on;
% end
% Sig3_f=Sig3_f';
% file3='Sig3_f.mat';
% file31='Sig3_f1.mat';
% save(file3,'Sig3_f');
% save(file31,'Sig3_f1');
