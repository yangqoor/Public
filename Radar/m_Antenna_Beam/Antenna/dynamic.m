%10*10的方阵工作于18Ghz时的方向图
% clear,clf;
% N=10;
% f=18e9;
% c=3e8;
% lemda=c/f;
% dx=lemda/4*(1:2:N-1);
% dy=lemda/4*(1:2:N-1);
% I=ones(N,N);
% 
% k=2*pi/lemda;
% theta0=0;
% fai0=pi/2;
% theta=linspace(0,pi/2,100);
% fai=linspace(0,2*pi,200);
% u=sin(theta')*cos(fai)-sin(theta0)*cos(fai0);
% v=sin(theta')*sin(fai)-sin(theta0)*sin(fai0);
% [r,l]=size(u);
% S=zeros(r,l);
% for m=1:N/2
%     for n=1:N/2
%         S=S+4*I(m,n)*cos(k*dx(n)*u).*cos(k*dy(m)*v);
%     end
% end
% Slog=20*log10(abs(S)/max(max(abs(S))));
% plot(theta*180/pi,Slog(:,1),'k');
% grid on;
% axis([0,90,-50,0]);
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%test the wideband performance of uniform equally spaced array
clear;
Length=31;
N=(Length+1)/2;
c=3e8;
f=1e9:1e8:18e9;
lemda=c./f;
lemdah=c/9e9;
d=(0:N-1)*lemdah;

k=2*pi./lemda;
res=1000;
theta=linspace(0,pi,res);
u=cos(theta);
mrsl=zeros(1,length(f));
bwnn=zeros(1,length(f));
for m=1:length(f)
    S=ones(size(u));
    for n=2:N
        S=S+2*cos(k(m)*d(n)*u);
    end
    S=abs(S);
    S=20*log10(S/max(S));
    for n=1:res/2
        if S(n)>S(n+1),brk=n;end
    end
    mrsl(m)=max(S(1:brk));
    bwnn(m)=2*(pi/2-theta(brk))*180/pi;
end
figure(1);
plot(f,mrsl);
figure(2);
plot(f,bwnn);