%minimum redundancy linear array
clear,clf;
Na=23;
%6;%90;%401;%101;%23;%the length of the array defined by the number of intervals
N=8;
%4;%16;%36;%17;%8;%the number of elements in the array
Nr=5;
%0;%0;%0%35;%5;%the number of redundances
A=[1 1 9 4 3 3 2];
%[1 3 2];%[1 1  6 6 6 11*ones(1,5) 5 5 3 1 1];%[1 1 12 2 6 6 8 6 19*ones(1,17) 11 2 5 6 3 2 2 3 1 1];%[1 1 3 5 5 11*ones(1,6) 6 6 6 1 1];%[1 3 6 6 2 3 2];%[1 1 9 4 3 3 2];the intervals of the elements(d);
c=3e8;
f=3e9;
lemda=c/f;
d=lemda/2;
x=zeros(1,Na+1);
x(1)=1;
for m=1:length(A);
    x(sum(A(1:m))+1)=1;
end
X=fft(x,length(x));
X1=fft(x,10*length(x));
X=abs(X);
X1=abs(X1);
X=fftshift(X);
X1=fftshift(X1);

k=2*pi/lemda;
theta=linspace(0,pi,1000);
u=cos(theta);
S0=zeros(1,length(u));
S=zeros(1,length(u));
for m=1:length(x)
    S0=S0+exp(i*k*(m-1)*d*u);
    if (x(m)==0)
        S=S+exp(i*k*(m-1)*d*u);
    end
end
S=abs(S);S0=abs(S0);
S=S/max(S);S0=S0/max(S0);
S=20*log10(S);S0=20*log10(S0);

figure(1);
plot(X,'k');
hold on;
plot(X,'ko');
hold off;
% figure(2);
% plot(theta*180/pi,S,'k','LineWidth',2);
% hold on;
% plot(theta*180/pi,S0,'k:','LineWidth',2);
% grid on;
% hold on;
% axis([0,180,-30,0]);
% set(gca,'Xtick',[0,30,60,90,120,150,180],'Ytick',[-30,-20,-10,0]);
% xlabel('\fontsize{16}\bftheta(degree)');
% ylabel('\fontsize{16}\bf·½ÏòÍ¼(dB)');
% hold off;
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% %minimum redundancy planar array(sparse array)
% clear;
% Na=29;
% %306;
% N=9;
% %31;
% A=[1 2 3 7 7 4 4 1];
% %[1 1 12 2 6 6 8 6 19*ones(1,12) 11 2 5 6 3 2 2 3 1 1];
% c=3e8;
% B=[6e9 7e9 8e9 9e9];
% lemda=c./B;
% 
% X=zeros(1,N);
% for m=1:length(A);
%     X(m+1)=sum(A(1:m));
% end
% Xfull=0:1:Na;
% for m=1:N
%     Xfull(X(m)+1)=0;
% end
% Xc=zeros(1,Na+1-N);
% n=0;
% for m=2:Na+1
%     if Xfull(m)~=0;n=n+1;Xc(n)=Xfull(m);end
% end
%         
% Lx=5;
% Ly=6;%Lx*Ly=Na+1
% P=zeros(Lx,Ly);
% for m=1:N
%     P(mod(X(m),Lx)+1,mod(X(m),Ly)+1)=1;
% end
% 
% 
% dx=lemda(1)/2*(0:Ly-1);
% dy=lemda(1)/2*(0:Lx-1);
% res=201;
% k=2*pi./lemda;
% theta=linspace(-pi/2,pi/2,res);
% phi=linspace(0,2*pi,res);%[0,pi/2];
% theta0=0;
% phi0=pi/2;
% u=sin(theta')*cos(phi)-sin(theta0)*cos(phi0);
% v=sin(theta')*sin(phi)-sin(theta0)*sin(phi0);
% u=u';v=v';
% S=zeros(size(u));
% for m=1:Lx
%     for n=1:Ly
%         if (P(m,n)==0),S=S+exp(i*k(2)*(dx(n)*u+dy(m)*v));end
%     end
% end
% S=abs(S);
% S=20*log10(S/max(max(S)));
% for m=1:res
%     for n=1:res
%         if(S(m,n)<-40),S(m,n)=-40;end
%     end
% end
% figure(1);
% surf(u,v,S)
% % for m=1:res
% %    plot(theta*180/pi,S(m,:),'k');
% %    hold on;
% % end
% % grid on;
% % axis([min(theta*180/pi),max(theta*180/pi),-30,0]);
% plcmnt=0.5*ones(20*Lx,20*Ly);
% for m=1:Lx
%     for n=1:Ly
%         if P(m,n)==1,plcmnt((m-1)*20+1:m*20-1,(n-1)*20+1:n*20-1)=0;end
%         if P(m,n)==0,plcmnt((m-1)*20+1:m*20-1,(n-1)*20+1:n*20-1)=1;end
%     end
% end
% plc=0.5*ones(20*Lx+1,20*Ly+1);
% plc(2:20*Lx+1,2:20*Ly+1)=plcmnt;
% imshow(flipud(plc));
