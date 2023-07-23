function [Alf,Opt,Dis,Nz,VV,Tf,Ur]=func_calc_QP(A,u,hx,ht,hdelta,delta,C,q,NN,z,t,T,d,reg);

%alf0=delta*norm(A)/(norm(u)-delta);Del=delta;%Del=delta*norm(u*h);
if delta == 0;alf0=1e-3*C*norm(A);else alf0=C*delta*norm(A)/(1-C*delta);end
Alf=[];Dis=[];Dz=[];Nz=[];VV=[];Tf=[];Ur=[];Opt=[];
 hhh = waitbar(0,'Please wait...');
 for kk=1:NN;
   alf=alf0*q.^(kk-1);
   [zz,dis,gam,psi,ur_psi]=Tikh_inv_QP(A,u,hx,ht,hdelta,delta,alf,reg);
   Alf=[Alf alf];Dis=[Dis dis];% Невязка 
   Opt=[Opt norm(zz-z)/norm(z)];% Критерий оптимального выбора
   Nz=[Nz sqrt(gam)];% Норма экстремали
   VV=[VV psi];% Quasiopt
   tf=alf*gam+dis^2;
   Tf=[Tf tf];% тих. ф-л
   Ur=[Ur ur_psi];% Обобщен. квазиоптимальн. выбор
   zrd=T*(zz+d);
   %figure(23);plot(t,z','r',t,zrd,'.-');alf
   %pause
   waitbar(kk/NN,hhh);
end   
close(hhh)