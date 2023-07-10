%sunthesis of unequally spaced linear array using legendre polynomial
clear;
Length=31;%number of the array
N=(Length+1)/2;
c=3e8;
f=3e9;
lemda=c/f;
k=2*pi/lemda;
I=zeros(1,N);
x=zeros(1,N);
x0=(0:1:N-1)*0.5;
d=lemda*[0 0.5 1 1.5 2 2.57 3.19 3.83 4.49 5.16 5.84 6.53 7.23 7.93 8.63 9.34];

theta=linspace(0,pi,1000);
u=cos(theta);
% M=100;%number of sampling points
% deltau=1/(M-1);
% alpha=zeros(1,N);alpha(1)=k*lemda*(x(1)+0.75)*deltau;
% beta=zeros(1,N);beta(1)=k*lemda*x(1)*deltau;
% f=zeros(N,N);f(1,1)=sqrt(2/(cos(beta(1))-cos(alpha(1))));
% F=zeros(1,N);
% E=[1,0.01*ones(1,M-1)];
% for m=1:M
%     F(1)=F(1)+epselon(m-1)*E(m)*Legendre_v(m-1,1/2,pi/(M-1));
% end
% I(1)=F(1)/f(1,1);I(2:N)=I(1)*2;
% for n=2:N
%     alpha(n)=k*lemda*(x(n-1)+0.75)*deltau;
%     for m=1:M
%         F(n)=F(n)+epselon(m-1)*E(m)*Legendre_v(m-1,1/2,alpha(n));
%     end
%     temp=0;
%     for p=1:n-1
%         f(n,p)=sqrt(2/(cos(beta(p))-cos(alpha(n))));
%         temp=temp+I(p)*f(n,p);
%     end
% 
%     beta(n)=acos(2*(I(n))^2/(F(n)-temp)^2+cos(alpha(n)));
%     if cos(beta(n))>=1
%         x(n)=x(n-1)+0.5;
%     elseif real(beta(n))>alpha(n)
%         x(n)=x(n-1)+0.5;
%     else 
%         x(n)=real(beta(n))/k/deltau;
%         if x(n)-x(n-1)<0.5,x(n)=x(n-1)+0.5;end
%     end
% end

%d=lemda*x;
d0=lemda*x0;
S=ones(1,length(u));S0=ones(1,length(u));
for n=2:N
    S=S+cos(k*d(n)*u);
    S0=S0+cos(k*d0(n)*u);
end
S=abs(S);S0=abs(S0);
S=20*log10(S/max(S));
S0=20*log10(S0/max(S0)+eps);
plot(theta*180/pi,S,'k');
hold on;
plot(theta*180/pi,S0,'k:');