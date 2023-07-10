%chebyshev planar array synthesis
clear;
M=7;
N=7;
B=20;%db
b=10^(B/20);
w0=cosh(acosh(b)/12);
lemda=1;
dx=lemda/2;
dy=lemda/2;
I=zeros(M,N);
for m=0:M-1
    for n=0:N-1
        for r=max([m n]):N
            I(m+1,n+1)=I(m+1,n+1)+(-1)^(N-r)*N*step_prod(N+r-1)*step_prod(2*r)*(w0/2)^(2*r)...
                /(step_prod(r-m)*step_prod(r-n)*step_prod(r+m)*step_prod(r+n)*step_prod(N-r));
        end
    end
end
theta0=0;
fai0=pi;
k=2*pi/lemda;
theta=linspace(-pi/2,pi/2,500);
fai=linspace(0,2*pi,500);
[U,V]=meshgrid(theta,fai);
u=k*dx/2*(sin(U).*cos(V)-sin(theta0)*cos(fai0));
v=k*dy/2*(sin(U).*sin(V)-sin(theta0)*sin(fai0));
S=zeros(size(u));
for m=0:M-1
    for n=0:N-1
        S=S+epselon(m)*epselon(n)*I(m+1,n+1)*cos(m*u).*cos(n*v);
    end
end
S=abs(S);
S=20*log10(S/max(max(S)));
%U=sin(meshgrid(theta)).*cos((meshgrid(fai))')-sin(theta0)*cos(fai0);%meshgrid(theta);
%V=sin((meshgrid(theta))').*sin(meshgrid(fai))-sin(theta0)*sin(fai0);%(meshgrid(fai))';
mesh(U,V,S);
% grid on;
%axis([0,pi/2,0,2*pi,-60,0]);