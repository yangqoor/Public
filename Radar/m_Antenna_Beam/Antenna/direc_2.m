%   this program is used to calculate the directivity of antenna arrays whose elements are dipoles
% all equally spaced and parallel, and the current of its elements have the same amplitude 
% distribution and linear phase distribution
function D=direc_2(num,N,theta0)
%num=[2 3];N=2;theta0=pi/2;
fai=pi/2; 
lemda=1;% it is not used
k=2*pi/lemda;% wave number
d=0:0.01*lemda:lemda;% distance between two adjacet element
% theta=0:0.01*pi:2*pi;
% u=k*d*(cos(theta)-cos(theta0))
% E(theta,fai)=abs((sin(n*u/2)./sin(u/2)).*f(theta,fai)),f(theta,fai)=sqrt(1-sin(theta).^2.*cos(fai).^2); 
% E stand for E(theta,fai) which is array factor,f for f(theta,fai) which is element factor

figure;
title('omnidirectional array');
hold on;
for n=1:N
Emax(n)=num(n).^2;
W(n,1)=2*num(n).^2/3;
for l=2:101
    W(n,l)=2*num(n)/3;
   for m=1:num(n)-1 
    W(n,l)=W(n,l)+2*(num(n)-m)*((1-1/(m*k*d(l))^2)*sin(m*k*d(l))+cos(m*k*d(l))/(m*k*d(l)))*cos(m*k*d(l)*cos(theta0))/(k*d(l)*m);
   end
end
D(n,:)=Emax(n)./W(n,:);
axis([0,1,0,10]);
plot(d/lemda,D(n,:));
hold on;
end
