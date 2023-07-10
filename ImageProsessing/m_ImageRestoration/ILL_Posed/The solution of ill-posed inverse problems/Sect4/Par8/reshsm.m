function z3=reshsm(s,zz,C_min,nummer);
%
%  Осредненная оценка для приближенного решения
if nummer>1;
ss=s';AB=[ones(size(ss)) ss ss.^2 ss.^3 ];aa=pinv(AB)*zz;z3=AB*aa;%ss.^4
nr=find(z3<C_min);z3(nr)=C_min;
elseif nummer==1;
   ss=s(1:52)';zzz=zz(1:52);
   AB=[ones(size(ss)) ss ss.^2 ss.^3 ];aa=pinv(AB)*zzz;z3=[AB*aa;C_min*ones(49,1)];
else
 N7=31;N3=N7;
 s7=linspace(0,1,N7);
 ss=s7';AB=[ones(size(ss)) ss ss.^2 ss.^3 ];aa=pinv(AB)*zz(1:N7);z33=AB*aa;%ss.^4
nr=find(z33<C_min);z33(nr)=C_min;z3=[z33;C_min*ones(N3-1,1)];
end   
% figure;plot(s,zz,'.-',s,z,'r.-',s,z3,'k.-')
