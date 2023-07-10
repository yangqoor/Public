%修正的泰勒法综合阵列，阵元数为奇数
Rl=15.5;  %the level difference of main lobe and left sidelobes db
Rr=26;  %the level difference of main lobe and right sidelobes db
bl=10^(Rl/20);
br=10^(Rr/20);
Al=acosh(bl)/pi;%a parpmeter in the null expression of the ideal space factor
Ar=acosh(br)/pi;
A=(Al+Ar)/2;
nbl=floor(2*Al^2+0.5)+2;%the first nb nulls of S is the same with the dieal space factor ,and n1>=2*A^2+0.5
nbr=floor(2*Ar^2+0.5)+2;
nl1=fliplr(-(1:nbl-1));
nr1=1:nbr-1;
n=[nl1 nr1];
ul0=-nbl*sqrt((Al^2+(-nl1-0.5).^2)./(Al^2+(nbl-0.5).^2));%the left positive nulls of the ideal space factor
ur0=nbr*sqrt((Ar^2+(nr1-0.5).^2)./(Ar^2+(nbr-0.5).^2));%the right positive nulls of the ideal space factor
u0=[ul0 ur0];
N=16;%the antenna number of the array
theta0=pi/2;
theta=0:pi/200:pi;
lemda=1;
d=lemda/2;
k=2*pi/lemda;
L=(N-1)*d;
u=L*(cos(theta)-cos(theta0))/lemda;
F=ones(1,length(u));
%F1=ones(1,length(n));
for m=1:nbl+nbr-2
    F=F.*(1-u/u0(m))./(1-u/n(m));
    %P(i)=step_prod(n1(i)+nb-1)*step_prod(-n1(i)+nb-1);
    %F1=F1.*(1-n1.^2./(u0(i))^2);
end
S=cosh(pi*A)*sin(pi*(u+eps)).*F./(pi*(u+eps));%taylor direction plot function
Slog=20*log10(abs(S)/max(abs(S)));
%p=2*pi*d*linspace(0,(N-1)/2,(N+1)/2)/L;
%I=ones(1,(N+1)/2);
%for l=1:nbl+nbr-2
 %   I=I+S_taylor(n(l),u0,nbl,nbr)*exp(-i*l*p);
 %end
%S1=I(1)*ones(1,length(u));
%for n=1:(N-1)/2
 %   S1=S1+2*I(n+1)*cos(2*pi*d*n*u/L);
 %end
%Slog1=20*log10(abs(S1)/max(abs(S1)));
figure(1);
plot(u,Slog);
grid on;
axis([-(N-1)/2,(N-1)/2,-50,0]);
%hold on;
%plot(u,Slog1,'r');
%hold off;