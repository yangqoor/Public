clear;
M=11;
N=11;
lemda=1;
dx=lemda/2;
dy=lemda/2;
I=ones(M,N);
% theta0=0;
% fai0=pi/2;
k=2*pi/lemda;
theta=linspace(-pi/2,pi/2,400);
fai=linspace(0,2*pi,400);
[U,V]=meshgrid(theta,fai);
u=k*dx*(sin(U).*cos(V));%-sin(theta0)*cos(fai0));
v=k*dy*(sin(U).*sin(V));%-sin(theta0)*sin(fai0));
% S=I(1,1)*ones(size(u));
% for m=2:M
%     S=S+2*I(1,m)*cos((m-1)*u);
% end
% for n=2:N
%     S=S+2*I(n,1)*cos((n-1)*v);
% end
% for m=2:M
%     for n=2:N
%         S=S+4*I(m,n)*cos((n-1)*u).*cos((m-1)*v);
%     end
% end
S=zeros(size(u));
for m=1:M
    for n=1:N
        S=S+I(m,n)*exp(i*((n-1)*u+(m-1)*v));
        S=S+4*I(m,n)*cos((2*n-1)/2*u).*cos((2*m-1)/2*v);
    end
end
S=abs(S);
S=20*log10(S/max(max(S)));
mesh(u,v,S);
%plot(theta,Slog(:,10),'k');
%plot3(theta,fai,Slog);
% grid on;
% 
% clear,clf;
% c=3e8;
% f=3e9;
% lemda=c/f;
% L=127;
% N=(127-1)/2;
% I=ones(1,N);
% d=lemda/2;
% 
% k=2*pi/lemda;
% theta=linspace(0,pi,1000);
% theta0=pi/2;
% u=cos(theta)-cos(theta0);
% S=ones(size(u));
% for n=1:N
%     S=S+2*cos(k*n*d*u);
% end
% S=abs(S);
% S=20*log10(S/max(S));
% plot(theta*180/pi,S);
% grid on;
% hold on;
% plot(theta*180/pi,-13.3*ones(1,length(theta)),'k--','LineWidth',2);
% axis([0,180,-40,0]);
% set(gca,'Xtick',[0,30,60,90,120,150,180],'Ytick',[-40,-30,-20,-10,0]);
% text(3,-12,'\fontsize{16}\bf-13.3');
% xlabel('\fontsize{16}\bftheta(degree)');
% ylabel('\fontsize{16}\bf·½ÏòÍ¼(dB)');
% hold off;