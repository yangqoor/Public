function [Alf,Opt,Dis,Nz]=func_QP(A,u,hx,hdelta,delta,C,q,NN,z,t,T,C_min);

%
n=length(z);
if delta == 0;alf0=1e-3*C*norm(A);else alf0=0.1*C*delta*norm(A)*norm(u)/(norm(u)-C*delta);end
Alf=[];Dis=[];Dz=[];Nz=[];VV=[];Tf=[];VAR =[];Opt=[];
 hhh = waitbar(0,'Please wait...');
 for kk=1:NN;waitbar(kk/NN,hhh);
   alf=alf0*q.^(kk-1);
   [zz,dis,gam]=Tikh_QP(A,u,hx,hdelta,delta,alf,T,C_min,kk-1);
   Alf=[Alf alf];Dis=[Dis dis];% Невязка 
   zrd=T*(zz(1:n)-zz(n+1:2*n));VAR=[VAR var1(zrd)];
   Opt=[Opt norm(zrd-z,inf)/norm(z,inf)];% Критерий оптимального выбора
   Nz=[Nz (gam)];% Норма экстремали
   %figure(55);subplot(1,2,1);plot(z,'r');hold on;plot(zrd,'.-');hold off;
   %subplot(1,2,2);plot(log10(Alf),VAR,'.-r');pause
   %figure(55);plot(zz,'r');pause
end   
close(hhh)