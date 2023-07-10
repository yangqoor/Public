function [Alf,Opt,Dis,Nz,Dz]=func_calc5(A,u,U,V,sig,X,y,w,delta,C,q,NN,z,DDD);
% для Comp_L_solut
% 
%
 
alf0=10*C*delta*norm(A)/(1-C*delta);
Alf=[];Dis=[];Dz=[];Nz=[];VV=[];Tf=[];Ur=[];Opt=[];
for kk=1:NN;alf=alf0*q.^(kk-1);
   [zz,dis,gam,gamw]=Tikh_inv55(A,u,U,V,sig,X,y,w,alf,DDD);
   Alf=[Alf alf];Dis=[Dis dis];% Невязка 
   Opt=[Opt norm(zz-z)/norm(z)];% Критерий оптимального выбора
   Nz=[Nz sqrt(gam)];% Норма экстремали в L
   Dz=[Dz sqrt(gamw)];% Норма экстремали в W
end   
