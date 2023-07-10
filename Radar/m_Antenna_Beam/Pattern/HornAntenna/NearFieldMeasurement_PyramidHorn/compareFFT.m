clc
clear all
W=100;       %定义频率
dx=1/(2*W);  %定义步长
N=2048;      %定义点数
n=0:N-1;

%%%%%%%%%%%%%%%%%%%%%%%%% 理论计算值  %%%%%%%%%%%%%%%%%%%%%%%%%%%%

w = 0:.0001:W;
FP=2./(1+(2*pi*w).^2);


%% %%%%%%%%%%%%%%%%%%%%%    直接求和      %%%%%%%%%%%%%%%%%%%%%%%%%
tic   %系统计时
for n1=0:N-1
    FS1=0;
    for k=0:N-1;
    FS2=dx.*exp(-abs((k-N/2).*dx)).*exp(1i*2*pi*k*n1/N);
    FS1=FS2+FS1;
    end
    FS(1,n1+1)=(-1).^n1.*FS1;
end
FS=abs(FS);
toc


%% %%%%%%%%%%%%%%%%%%%%%    FFT算法      %%%%%%%%%%%%%%%%%%%%%%%%%
k=0:N-1;
w1=n./(N*dx);  %采样以后的频率
Fk=dx.*exp(-abs((k-N/2).*dx));
tic
FF=fft(Fk,N);
FF=abs(FF);
toc

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1)
title('直接求和计算结果与理论结果','FontName','华文隶书',...
      'FontWeight','Bold','FontSize',16)
hold on
grid on;
plot(w,FP,'--r','LineWidth',1.5);
stem(w1,FS);

legend('理论法结果','直接求和结果')
axis([0 2 0 2]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(2)
title('FFT计算结果与理论结果','FontName','华文隶书',...
      'FontWeight','Bold','FontSize',16)
hold on;
grid on;

plot(w,FP,'--r','LineWidth',1.5);
stem(w1,FF);

legend('理论结果','FFT计算结果')
axis([0 2 0 2]) 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(3)
title('三种方法比较','FontName','华文隶书',...
      'FontWeight','Bold','FontSize',16)
hold on
grid on;

plot(w,FP,'--r','LineWidth',1.5);
stem(w1,FS);
plot(w1,FF,'*k');

legend('理论结果','直接求和结果','FFT计算结果')
axis([0 2 0 2]);
