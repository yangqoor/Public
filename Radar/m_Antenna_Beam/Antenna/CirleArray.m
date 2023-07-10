%圆环阵列的方向图计算
clear,clf;
N=19;%阵元数
D=[1 4 5 6 7 9 11 16 17];
lemda=1;
r=N*lemda/pi/4;
fain=2*pi/N*(1:N);
x=ones(1,N);
for m=1:length(D)
    x(D(m)+1)=0;
end
I0=ones(1,N);
I=I0.*x;


k=2*pi/lemda;
theta0=0;
fai0=pi/2;
alpha=0;%-k*r*sin(theta0)*cos(fai0-fain);
theta=linspace(-pi/2,pi/2,200);%0:pi/200:pi/2;
fai=linspace(0,2*pi,200);%0:pi/200:2*pi;
l1=length(theta);
l2=length(fai);
rou=r*sin(theta');
kesy=fai;%cos(kesy)=(sin(theta')*cos(fai)-sin(theta0)*sin(fai0))*r./((sin(theta')*cos(fai)-sin(theta0)*cos(fai0)).^2+(sin(theta')*sin(fai)-sin(theta0)*sin(fai0)).^2).^0.5
u=zeros(N,l2);
for n=1:N
    u(n,:)=cos(fai-fain(n));
end
S=sum(I.^2)*ones(l1,l2);
for m=1:N-1
    for n=0:N-1-m
        S=S+2*I(n+1)*I(m+n+1)*cos(k*meshgrid(rou).*meshgrid((u(m+n+1,:)-u(n+1,:)))');
    end
end

M=10;
E=N*besselj(0,k*meshgrid(rou));%*ones(1,l2);
%for m=1:M
    %E=E+2*N*besselj(m*N,k*rou)*cos(m*N*(pi/2-kesy));
    %end
Slog=10*log10(abs(S)/max(max(abs(S))));
Elog=20*log10(abs(E+1)/max(max(abs(E+1))));
% figure(1);
% plot(theta*180/pi,Slog(1,:),'k:');                 
% grid on;
% hold on;
% plot(theta*180/pi,Elog(1,:),'k');
% axis([-90,90,-40,0]);
% hold off;
figure(2);
X=meshgrid(theta*180/pi);
Y=(meshgrid(fai*180/pi))';
surf(X,Y,Slog);
