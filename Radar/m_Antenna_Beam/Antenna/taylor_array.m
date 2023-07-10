%泰勒法综合阵列，阵元数为奇数
R0=20;  %the level difference of main lobe and sidelobes db
b=10^(R0/20);
A=acosh(b)/pi;%a parpmeter in the null expression of the ideal space factor
nb=floor(2*A^2+0.5)+4;%the first nb nulls of S is the same with the dieal space factor ,and n1>=2*A^2+0.5
n1=1:nb-1;
delta=nb/sqrt(A^2+(nb-0.5)^2);%expanding factor
u0=delta*sqrt(A^2+(n1-0.5).^2);%the positive nulls of the ideal space factor
N=16;%the antenna number of the array
theta0=pi/2;
theta=0:pi/200:pi;
lemda=1;
d=lemda/2;
k=2*pi/lemda;
L=(N-1)*d;
u=L*(cos(theta)-cos(theta0))/lemda;
F=ones(1,length(u));
F1=ones(1,length(n1));
for i=1:nb-1
    F=F.*(1-(u/u0(i)).^2)./(1-(u/i).^2);
    P(i)=step_prod(n1(i)+nb-1)*step_prod(-n1(i)+nb-1);
    F1=F1.*(1-n1.^2./(u0(i))^2);
end
S=cosh(pi*A)*sin(pi*(u+eps)).*F./(pi*(u+eps));%taylor direction plot function
Sn=(prod(n1))^2*F1./P;%it is used to caculate the magnitude distribution of current
p=2*pi*d*linspace(0,(N-1)/2,(N+1)/2)/L;
I=ones(1,floor((N+1)/2));
for j=1:nb-1
    I=I+2*Sn(j)*cos(j*p);
end
Slog=20*log10(abs(S)/max(abs(S)));
S1=I(1)*ones(1,length(u));
for n=1:(N-1)/2
    S1=S1+2*I(n+1)*cos(2*pi*d*n*u/L);
end
Slog1=20*log10(abs(S1)/max(abs(S1)));
figure(1);
plot(u,Slog,'k:');
grid on;
axis([-(N-1)/2,(N-1)/2,-70,0]);
hold on;
plot(u,Slog1,'r');
hold off;
%figure(2);
%plot(u,Slog1-Slog);
