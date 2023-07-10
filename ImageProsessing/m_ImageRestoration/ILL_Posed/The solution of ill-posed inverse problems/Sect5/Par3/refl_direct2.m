function [F,G]=refl_direct2(nz,R_ideal,R,nz1,nz2,n,k,h,ris0)
% 
F=sum(nz);G=[];

if ris0(2)>=3;
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
  R_min_optical_length=norm(1-T-R_ideal)/sqrt(length(k))
figure(ris0(2));subplot(2,1,2);plot(2*pi./k,1-T,'.-');
    xlabel('\lambda');ylabel('R(\lambda)');%disp(1-T);

end