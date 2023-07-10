function [Alf,Opt,Dis,Nz,Optl,Disl,Nzl]=func_calc_Tikh(A,u,hx,delta,C,q,NN,z);

if delta == 0;alf0=1e-3*C*norm(A);
else alf0=40*C*delta*norm(A)*norm(u)/(norm(u)-C*delta);end
Alf=[];Dis=[];Nz=[];Opt=[];Disl=[];Nzl=[];Optl=[];
 %hhh = waitbar(0,'Please wait...');
 for kk=1:NN;
   alf=alf0*q.^(kk-1);
   [zz,dis,gam,zzl,disl,gaml]=Tikh_inv(A,u,hx,alf);
   Alf=[Alf alf];Dis=[Dis dis];% Невязка 
   Opt=[Opt norm(zz-z)/norm(z)];% Критерий оптимального выбора
   Nz=[Nz sqrt(gam)];% Норма экстремали
   Disl=[Disl disl];% Невязка 
   Optl=[Optl norm(zzl-z)/norm(z)];% Критерий оптимального выбора
   Nzl=[Nzl sqrt(gaml)];
   %waitbar(kk/NN,hhh);
end   
%close(hhh)