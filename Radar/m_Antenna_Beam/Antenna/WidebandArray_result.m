clear,clf;
Nf=6;%工作频带内有Nf个频率
N=20;%每行每列阵元数
fh=18e9;%最高工作频率
res=201;
theta0=0;
fai0=pi/2;
fai=linspace(0,2*pi,res);
theta=linspace(-pi/2,pi/2,res);
u=sin(meshgrid(theta)).*cos((meshgrid(fai))')-sin(theta0)*cos(fai0);
v=sin(meshgrid(theta)).*sin((meshgrid(fai))')-sin(theta0)*sin(fai0);
num=1:Nf;

E1=WidebandArray(N,num(1),fh,u,v);
E2=WidebandArray(N,num(2),fh,u,v);
E3=WidebandArray(N,num(3),fh,u,v);
E4=WidebandArray(N,num(4),fh,u,v);
E5=WidebandArray(N,num(5),fh,u,v);
E6=WidebandArray(N,num(6),fh,u,v);
Elog1=20*log10(E1/max(max(E1)));
Elog2=20*log10(E2/max(max(E2)));
Elog3=20*log10(E3/max(max(E3)));
Elog4=20*log10(E4/max(max(E4)));
Elog5=20*log10(E4/max(max(E5)));
Elog6=20*log10(E6/max(max(E6)));
E=Elog6;
for m=1:res
    for n=1:res
        if(E(m,n)<-50),E(m,n)=-50;end
    end
end
figure(1);
surf(u,v,E);
% for m=1:500
% hold on;
% plot(theta*180/pi,Elog1(m,:),'k');
% plot(theta*180/pi,Elog2(1,:),'k:');
% plot(theta*180/pi,Elog3(1,:),'g');
% plot(theta*180/pi,Elog4(1,:),'m');
% plot(theta*180/pi,Elog5(1,:),'r');
% end
% grid on;
% axis([-90,90,-50,0]);
% hold off;
% figure(2);
% u=meshgrid(sin(theta)).*(meshgrid(cos(fai)))';
% v=meshgrid(sin(fai)).*(meshgrid(sin(theta)))';
% [U,V]=meshgrid(theta,fai);
% plot3(u,v,E3);