%linear array defined by weight of kaiser window
% N=41;%elements'number
% f=3e9;
% c=3e8;
% lemda=c/f;
% d=lemda/2;
% %weight
% beta=6;
% ns=-(N-1)/2:1:(N-1)/2;
% I=besseli(0,beta*sqrt(1-(2*ns/N).^2));
% I=I/I((N+1)/2);
% k=2*pi/lemda;
% theta=linspace(0,pi,1000);
% u=cos(theta);
% S=zeros(1,length(u));
% for n=0:N-1
%     S=S+I(n+1)*exp(i*(n-(N-1)/2)*k*d*u);
% end
% S=abs(S);
% S=S/max(S);
% S=20*log10(S);
% plot(u,S);
%--------------------------------------------------------------------------
%planar array defined by weight of kaiser window
clear;
M=5;
N=5;
f=3e9;
c=3e8;
lemda=c/f;
dx=lemda/2;
dy=lemda/2;
%weight
beta=5;
I=zeros(M,N);
for m=1:M
    for n=1:N
%         if sqrt(m^2+n^2)<10
        I(m,n)=0.4*pi*besselj(1,0.4*pi*sqrt(m^2+n^2))/(2*pi*sqrt(m^2+n^2))*...
            besseli(0,beta*sqrt(1-(sqrt(m^2+n^2)/14).^2))/besseli(0,beta);
%         end
    end
end
k=2*pi/lemda;
theta=linspace(-pi/2,pi/2,500);
phi=linspace(0,2*pi,500);
u=sin(theta')*cos(phi);
v=sin(theta')*sin(phi);
S=zeros(size(u));
for m=1:M
    for n=1:N
        S=S+4*I(m,n)*cos(k*(2*n-1)/2*dx*u).*cos(k*(2*m-1)/2*dx*v);
    end
end
S=abs(S);
S=S/max(max(S));
% S=20*log10(S);
% plot(theta,S(:,1));
mesh(u,v,S);