function [G,Geq,GC,GCeq]=grfun_W(z,H,y,r,h)

Dz=diff(z);G1=[];
G=norm(z)^2+norm(Dz/h)^2-r;%[z(1)^2+z(end)^2+Dz(1)^2+Dz(end)^2-0.01;];
GC=[];
%G=sum(x.*log(x))-r;GC=log(x)+1;
Geq=[];GCeq=[];