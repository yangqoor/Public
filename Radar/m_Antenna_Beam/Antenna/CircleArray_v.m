function [E,Ev]=CircleArray_v(N,r,I,theta)
%主瓣最大值指向Z轴的圆环阵

%N=20;%阵元数
fain=2*pi/N*(1:N);
%I=ones(1,N);
lemda=1;
%r=2*lemda;
k=2*pi/lemda;

theta0=0;
fai0=pi/2;
alpha=-k*r*sin(theta0)*cos(fai0-fain);
%theta=0:pi/200:pi/2;
fai=linspace(0,2*pi,200);%0:pi/200:2*pi;
l1=length(theta);
l2=length(fai);
rou=r*sin(theta');
kesy=fai;%cos(kesy)=(sin(theta')*cos(fai)-sin(theta0)*sin(fai0))*r./((sin(theta')*cos(fai)-sin(theta0)*cos(fai0)).^2+(sin(theta')*sin(fai)-sin(theta0)*sin(fai0)).^2).^0.5
u=zeros(N,l2);
for n=1:N
    u(n,:)=cos(fai-fain(n));
end
M=10;
Ev=N*besselj(0,k*meshgrid(rou));
for m=1:M
    Ev=Ev+2*N*besselj(m*N,k*meshgrid(rou)).*cos(m*N*(meshgrid(pi/2-kesy))');
end
E=N*besselj(0,k*meshgrid(rou));%*ones(1,l2);
