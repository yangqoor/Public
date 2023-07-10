function [Alf,Opt,Dis,Nz,Dz,Psi]=func_calc5(A,u,U,V,sig,X,y,w,delta,C,q,NN,z,DDD);
% ��� Comp_L_solut
% 
%
 
alf0=15*C*delta*norm(A)/(1-C*delta);
Alf=[];Dis=[];Dz=[];Nz=[];VV=[];Tf=[];Ur=[];Opt=[];Psi=[];
for kk=1:NN;alf=alf0*q.^(kk-1);
  [zz,dis,gam,gamw,psi]=Tikh_inv55(A,u,U,V,sig,X,y,w,alf,DDD);%size(zz)
  %size(z)
  %figure(77);plot(z,'r');hold on;plot(zz,'b.-');hold off;title(num2str(alf));pause
   Alf=[Alf alf];Dis=[Dis dis];% ������� 
   Opt=[Opt norm(zz-z)/norm(z)];% �������� ������������ ������
   Nz=[Nz sqrt(gam)];% ����� ���������� � L
   Dz=[Dz sqrt(gamw)];% ����� ���������� � W
   Psi=[Psi psi];% ��� ����������������� ������
end   
