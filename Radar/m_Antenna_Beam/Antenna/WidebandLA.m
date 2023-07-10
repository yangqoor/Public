%program for caculating the radiation pattern of symmmetric unequally spaced linear array
clear,clf;
%parameters of the array
Nf=6;%工作频带内有Nf个频率
L=20;%number of the inner elements operating on the highest frequency
N=L/2;
fh=18e9;%最高工作频率
num=1:Nf;
c=3e8;%光速
lemdah=c/fh;%最高工作频率下的波长
lemda=[lemdah,(L/(L-2)).^(1:Nf-1)*lemdah];%各工作频率下的波长


x=zeros(Nf,N+Nf-1);%to define number of operating elements
for m=1:Nf
    x(m,1:N+m-1)=1;
end
%阵元位置
d=zeros(1,N+Nf-1);
for m=1:N
    d(m)=(2*m-1)/2*lemda(1)/2;
end
for m=N+1:N+Nf-1
    d(m)=N*lemda(1)/2+sum(lemda(2:m-N)/2)+lemda(m-N+1)/4;
end
I=ones(1,N+Nf-1);

nf=1;%define the operating frequency
k=2*pi/lemda(num(nf));
theta0=pi/2;
theta=linspace(0,pi,1000);
u=cos(theta')-cos(theta0);
S=zeros(length(u),1);
for m=1:N+Nf-1
    if(x(nf,m)~=0)
       S=S+2*I(m)*cos(k*d(m)*u);
    end
end
S=abs(S);S=S/max(S);
S=20*log10(S+eps);
plot(theta*180/pi,S,'k');
grid on;
axis([min(theta*180/pi),max(theta*180/pi),-40,0]);