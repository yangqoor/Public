function [zro,diso,alf]=Tikh_reg_smooth(KK1,ud1,h,delta,C)
% –егул€ризаци€ с выбором параметра по принципу сглаживающего функционала
alf0=1*delta*norm(KK1)/(norm(ud1)-delta);Del=delta;%Del=delta*norm(u*h);
Alf=[];Dis=[];Dz=[];Nz=[];VV=[];Tf=[];
ken=min(log10(alf0)-log10(eps),15);
for kk=1:ken;alf=alf0*(0.1).^(kk-1);
   [zr3,dis3,v3]=Tikh_alf1(KK1,ud1,h,delta,alf);Alf=[Alf alf];Dis=[Dis dis3];
   nz=norm(zr3);Nz=[Nz nz];VV=[VV v3];
   tf=(alf*norm(zr3)^2+(dis3*norm(ud1))^2)/norm(ud1)^2;
   Tf=[Tf tf];
end   
iz=min(find(Tf<=C*Del^2));alf=Alf(iz);
[zro,diso,vo]=Tikh_alf1(KK1,ud1,h,delta,alf);
%figure(101);plot(log10(Alf),Tf, 'r.-',[-18 log10(alf0)],[C*Del^2 C*Del^2],'k-',...
%   log10(Alf(iz)),Tf(iz),'bo');
% lg(alf)=lg(alf0)-kk+1 => ken=lg(alf0)-lg(alf)+1