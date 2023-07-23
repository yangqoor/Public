function [F,G]=refl_constr1(nz,R_ideal,R,nz1,nz2,n,k,h,ris0)
% 
% Вычисление коэф-та отражения системы по заданному распределению
% оптических длин nz*h^ R(k)=1-T(k). Вычисление ограничения ||R(k)||-R.

nz=nz-i*0.00002;% Учет поглощения

for ndl=1:length(k);
fi=k(ndl)*nz1*h;cs=cos(fi);sn=sin(fi);A=[cs i*sn/nz1;i*nz1*sn cs];
for ni=1:n;
  fi=k(ndl)*nz(ni)*h;cs=cos(fi);sn=sin(fi);A_ni=[cs i*sn/nz(ni);i*nz(ni)*sn cs];
  A=A_ni*A;
end
fi=k(ndl)*nz2*h;cs=cos(fi);sn=sin(fi);A1=[cs i*sn/nz2;i*nz2*sn cs];A=A1*A;
t(ndl)=2*nz2/(nz2*A(1,1)+nz1*A(2,2)+nz1*nz2*A(1,2)+A(2,1));
T(ndl)=nz1/nz2*abs(t(ndl))^2;
end
if ris0(2)==1;F=norm(1-T-R_ideal)/sqrt(length(k))-R;elseif ris0(2)==2;
F=norm(1-T-R_ideal,inf)-R;else error('Неверно задано ris0');end
  
  if ris0(1)>0;figure(ris0(2));subplot(2,1,2);plot(2*pi./k,1-T,'.-');
    xlabel('\lambda');ylabel('R(\lambda)');%disp(1-T);
  end
G=[];