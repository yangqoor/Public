%hexagonal planar array
Nx=11;%the number of elements in the horizontal row through the origin
Nh=1+6*sum(1:(Nx-1)/2);%the number of elements in the array
c=3e8;
f=3e9;
lemda=c/f;
dx=lemda/2;
dy=sqrt(3)*lemda/4;


k=2*pi/lemda;
theta=linspace(-pi/2,pi/2,500);
phi=linspace(0,2*pi,500);
u=sin(theta')*cos(phi);
v=sin(theta')*sin(phi);
ur=(u.^2+v.^2).^0.5;
S=zeros(size(u));
R=2.75*lemda;
for m=-(Nx-1)/2:(Nx-1)/2
    for n=0:Nx-abs(m)-1
        I=1-(((n-(Nx-abs(m)-1)/2)*dx)^2+(m*dy)^2)/R^2;
        S=S+I*exp(i*k*((n-(Nx-abs(m)-1)/2)*dx*u+m*dy*v));
    end
end
S=abs(S);
S=20*log10(S/max(max(S)));
mesh(u,v,S);
        