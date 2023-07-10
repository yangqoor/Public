function [Alf,Opt,Dis,Nz,VV,Tf,Dz,Ur]=func_calc4(A,u,U,V,sig,X,y,w,delta,C,q,NN,z,DDD);
% для Comp_L_solut
% 
%
 
alf0=10*C*delta*norm(A)/(1-C*delta);
Alf=[];Dis=[];Dz=[];Nz=[];VV=[];Tf=[];Ur=[];Opt=[];
for kk=1:NN;alf=alf0*q.^(kk-1);
   [zz,dis,gam,psi,ur_psi,gamw]=Tikh_inv44(A,u,U,V,sig,X,y,w,alf,DDD);
   Alf=[Alf alf];Dis=[Dis dis];% Невязка 
   Opt=[Opt norm(zz-z)/norm(z)];% Критерий оптимального выбора
   Nz=[Nz sqrt(gam)];% Норма экстремали в L
   Dz=[Dz gamw];% Норма экстремали в W
   VV=[VV psi];% Quasiopt
   tf=alf*gamw+dis^2;
   Tf=[Tf tf];% тих. ф-л
   Ur=[Ur ur_psi];% Обобщен. квазиоптимальн. выбор
end   
