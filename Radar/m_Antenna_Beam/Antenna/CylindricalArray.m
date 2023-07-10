%cylindrical arrays
clear;
c=3e8;%π‚ÀŸ
f=3e9;
lemda=c/f;
M=10;%number of circles
N=20;%number of elements in each circle
R=N*lemda/2/pi;%radius of the circle

k=2*pi/lemda;
fai=(1:N)*2*pi/N;
z=(0:M-1)*lemda/2;
theta0=pi/2;
phi0=pi/2;
theta=linspace(0,pi,200);
phi=linspace(0,2*pi,200);
u=zeros(length(theta),length(theta));
S=zeros(length(theta),length(theta));
for m=1:M
    for n=1:N
        u=meshgrid(sin(theta)).*(meshgrid(cos(phi-fai(n))))'-...
          sin(theta0)*cos(phi0-fai(n));
        S=S+exp(i*k*(R*u+z(m)*meshgrid(cos(theta))));
    end
end
S=abs(S);
S=S/max(max(S));
S=20*log10(S);
% plot(theta/pi,S(1,:));
% X=sin(theta')*cos(phi);
% Y=sin(theta')*sin(phi);
[X,Y]=meshgrid(theta,phi);
surf(X,Y,S);