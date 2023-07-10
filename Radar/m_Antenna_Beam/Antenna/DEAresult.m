%利用DEA对阵列进行优化所得到的结果
clear,clf;
N=32;
c=3e8;
f=3e9;
lemda=c/f;
dmin=0.5*lemda;
dmax=0.6*lemda;
d=lemda*[0.25 0.75 1.25 1.75 2.25 2.75 3.27 3.87 4.47 5.06 5.66 6.26 6.86 7.46 8.06 8.66];
%[0.25,0.75,1.25,1.75,2.26,2.76,3.30,3.89,4.49,5.09,5.69,6.29,6.79,7.39,7.99,8.59];
p=pi/180*zeros(1,N/2);
%[47.6,53.1,57.3,59.2,54.5,49.9,52.7,62.8,53.8,23.8,57.5,120.5,0,60.5,40.9,55.2];
k=2*pi/lemda;
theta0=pi/2;
theta=linspace(0,pi,2000);
u=cos(theta)-cos(theta0);
S=zeros(1,length(u));
for m=1:N/2
    S=S+2*cos(k*d(m)*u)*exp(i*p(m));
end
S=abs(S);
S=20*log10(S/max(S));
%directivity
D0=N;
D1=2*sum(sinc(2*k*d/pi));
D2=0;
for m=1:N/2-1
    for n=0:N/2-1-m
        D2=D2+4*(sinc(k*(d(m+n+1)+d(n+1))/pi)+sinc(k*(d(m+n+1)-d(n+1))/pi));
    end
end
D=N^2/(D0+D1+D2);
D=10*log10(D)
plot(u,S,'k');%theta*180/pi