function z3=reshsm1(s,zz,C_min,nummer);
%
%  Осредненная оценка для приближенного решения
if nummer>1;
ss=s';AB=[ones(size(ss)) ss ss.^2 ss.^3 ];aa=pinv(AB)*zz;z3=AB*aa;%ss.^4
nr=find(z3<C_min);z3(nr)=C_min;
else   
   ss=s(1:31)';zzz=zz(1:31);
   AB=[ones(size(ss)) ss ss.^2 ss.^3 ];aa=pinv(AB)*zzz;z3=[AB*aa;C_min*ones(30,1)];
end   
