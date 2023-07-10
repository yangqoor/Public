%   this program is used to calculate the directivity of antenna arrays whose elements are all
% equally spaced and omnidirectional, and the current of its elements have the same amplitude 
% distribution and linear phase distribution
function D=direc_1(num,N,theta0)

lemda=1;% it is not used
k=2*pi/lemda;% wave number
d=0:0.01*lemda:2*lemda;% distance between two adjacet element
% theta=0:0.01*pi:2*pi;
% u=k*d*(cos(theta)-cos(theta0))
% E(theta,fai)=abs((sin(n*u/2)/sin(u/2))*f(theta)),f(theta)=1;
% E stand for E(theta,fai),f for f(theta,fai) which is element factor
if theta0==pi/2
   Db=20*d/lemda;% an aproximate formula for a long array;
else
   Db=40*d/lemda;
end
figure(1);
plot(d/lemda,Db);
title('omnidirectional array');
hold on;
for n=1:N
Emax(n)=num(n).^2;
W(n,1)=num(n).^2;
for l=2:201
    W(n,l)=num(n);
   for m=1:num(n)-1 
    W(n,l)=W(n,l)+2*(num(n)-m)*sin(m*k*d(l)).*cos(m*k*d(l)*cos(theta0))./(k*d(l)*m);
   end
end
D(n,:)=Emax(n)./W(n,:);
axis([0,2,0,20]);
plot(d/lemda,D(n,:));
hold on;
end
