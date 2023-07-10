function U=potenz1(z0,H,X,PHI,phi)
% вертикальная составляющая силы тяжести
a=z0(1);b=z0(2);fi0=z0(3);
RR=1./sqrt(cos(PHI-fi0).^2/a^2+sin(PHI-fi0).^2/b^2);A=-yadro(X,H,RR,PHI);
U=trapz(phi,A);
