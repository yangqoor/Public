%计算等间距、等电流幅度分布，线性步进电流相位的阵列方向图
theta0=pi/2;
I0=1;   %equally spaced, uniform amplitude, linear stepped phase
N=7;
theta=0:pi/200:pi;
K=length(theta);
lemda=1;
d=lemda/2;
k=2*pi/lemda;
u=k*d*(cos(theta)-cos(theta0));
%% equally spaced, uniform amplitude, linear stepped phase
if u==0
    S1=N*ones(1,length(u));
else
   S1=I0*abs(sin(N*u/2)./sin(u/2));
end
Slog1=20*log10(S1/N);
figure(1);
plot(u,Slog1);

