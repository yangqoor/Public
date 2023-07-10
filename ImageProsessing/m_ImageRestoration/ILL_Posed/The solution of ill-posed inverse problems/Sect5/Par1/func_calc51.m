function [Alf,Opt,Dis,Nz,Dz,Psi]=func_calc51(A,u,U,V,sig,X,y,w,delta,C,q,NN,z,DDD);
% для Spec_2_conc_tikh
% 
%
 
alf0=10000*C*delta*norm(A)/(1-C*delta);
Alf=[];Dis=[];Dz=[];Nz=[];VV=[];Tf=[];Ur=[];Opt=[];Psi=[];
for kk=1:NN;alf=alf0*q.^(kk-1);
  [zz,dis,gam,gamw,psi]=Tikh_inv55(A,u,U,V,sig,X,y,w,alf,DDD);
  %figure(77);plot(z,'r');hold on;plot(zz,'b.-');hold off;title(num2str(alf));pause
   Alf=[Alf alf];Dis=[Dis dis];% Невязка 
   Opt=[Opt norm(zz-z)/norm(z)];% Критерий оптимального выбора
   Nz=[Nz sqrt(gam)];% Норма экстремали в L
   Dz=[Dz sqrt(gamw)];% Норма экстремали в W
   Psi=[Psi psi];% Для квазиоптимального выбора
end   
