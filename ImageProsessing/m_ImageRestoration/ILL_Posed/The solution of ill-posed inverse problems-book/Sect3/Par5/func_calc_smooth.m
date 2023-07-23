function [Alf,Opt,Dis,Nz]=func_calc_smooth(A,u,delta,C,q,NN,z);

if delta == 0;alf0=1e-3*C*norm(A);
else alf0=100*C*delta*norm(A)*norm(u)/(norm(u)-C*delta);end
Alf=[];Dis=[];Nz=[];Opt=[];Disl=[];Nzl=[];Optl=[];
 hhh = waitbar(0,'Please wait...');
 for kk=1:NN;waitbar(kk/NN,hhh);
   alf=alf0*q.^(kk-1);
   [zz,dis,gam]=Tikh_inv_smooth(A,u,alf);
   Alf=[Alf alf];Dis=[Dis dis];% Невязка 
   Opt=[Opt norm(zz-z)/norm(z)];% Критерий оптимального выбора
   Nz=[Nz sqrt(gam)];% Норма экстремали
   %figure(8);plot(zz,'.-');hold on;plot(z,'r');hold off;pause
   
end   
close(hhh)