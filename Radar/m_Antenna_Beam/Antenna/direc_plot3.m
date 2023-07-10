%计算等间距、等电流幅度分布，非线性步进电流相位的阵列方向图
theta0=pi/2;
delta=[0 0 -pi/9 -pi/6 -3*pi/9]; 
Ir=cos(delta);   %equally spaced, uniform amplitude, nonlinear stepped phase
Ii=sin(delta);
N=5;
theta=pi/100:pi/200:99*pi/100;
K=length(theta);
lemda=1;
d=lemda/2;
k=2*pi/lemda;
u=k*d*(sin(theta)-sin(theta0));
S=zeros(1,length(u));
for i=0:N-1
   S=S+2*(Ir(i+1)*cos(i*u)+Ii(i+1)*sin(i*u));
end
Slog=20*log10(abs(S)/max(abs(S)));
figure(1);
plot(u,Slog);
%polar(u,S);
