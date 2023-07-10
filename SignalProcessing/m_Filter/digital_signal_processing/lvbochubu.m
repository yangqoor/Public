clear all
T0=2;
Ts=0.04;
N=T0/Ts;
n=0:N-1;
nTs=n*Ts;
xn=4+2*cos(2*pi*5*nTs)+0.8*cos(2*pi*10*nTs)+0.5*sin(2*pi*22*nTs)+0.5*cos(2*pi*30*nTs)+0.3*cos(2*pi*42*nTs)+0.1*rand(1,N);

figure
subplot(2,1,1);
plot(n,xn,'-*r');
xlabel('n');ylabel('x(n)');title('采样信号x(n)');

subplot(2,1,2);
plot(nTs,xn,'-*r');
hold on
xlabel('t/s');ylabel('x(n)');title('采样信号x(n)');

Xk=m_DFT(xn);
Xk=Xk*Ts;
K=size(Xk,2);
Am_Xk=abs(Xk(1:K));

figure
subplot(3,1,1);
plot(0:K-1,Am_Xk,'-*');
xlabel('k');ylabel('X(K)');title('幅度谱');
%Fs=1/Ts;
%f0=Fs/K;
f0=1/T0;
f=(0:K-1)*f0;
subplot(3,1,2);
plot(f,Am_Xk,'-*');
xlabel('频率/Hz');ylabel('幅度');title('幅度谱');

Am_Xk(1)=Am_Xk(1)/2;
subplot(3,1,3);
plot(f(1:N/2),Am_Xk(1:N/2),'-*');
xlabel('频率/Hz');ylabel('幅度');title('幅度谱');

X_k=2/N*fft(xn);
X_k(1)=X_k(1)/2;
f0=1/T0;
f=(0:K-1)*f0;
figure
subplot(2,1,1);
plot(f,abs(X_k));
xlabel('频率/Hz');ylabel('幅度');title('幅度谱X(f)');

subplot(2,1,2);
plot(f(1:N/2),abs(X_k(1:N/2)));
xlabel('频率/Hz');ylabel('幅度');title('幅度谱X(f)');