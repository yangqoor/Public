function [zro,diso,alf]=Tikh_reg_discr5(KK1,ud1,L,delta,hdelta,C,q,NN)
% Регуляризация с выбором параметра по ОПН
alf0=10*delta*norm(KK1)/(norm(ud1)-delta);%Del=delta;%Del=delta*norm(u*h);
alf0=10*C*delta*norm(KK1)/(1-C*delta);
Alf=[];Dis=[];Dz=[];Nz=[];VV=[];Tf=[];
%
h8 = waitbar(0,'Please wait...');
for kk=1:NN;alf=alf0*(q).^(kk-1);
   [zr3,dis3,v3]=Tikh_alf5(KK1,ud1,L,alf);Alf=[Alf alf];Dis=[Dis dis3];
   nz=norm(zr3);Nz=[Nz nz];VV=[VV sqrt(v3)];
   waitbar(kk/NN,h8); 
 end   
  close(h8)
 Del=delta*norm(ud1)+hdelta*norm(KK1)*Nz;
iz=min(find(Dis<=Del));alf=Alf(iz);
[zro,diso,vo]=Tikh_alf15(KK1,ud1,L,alf);
%figure(101);plot(log10(Alf),Dis, 'r.-',log10(Alf),Del,'k-',...
%   log10(Alf(iz)),Dis(iz),'r*');hold off
% lg(alf)=lg(alf0)-kk+1 => ken=lg(alf0)-lg(alf)+1