function Kr=direct_kriv(Dis,Nz,Riss)
%     Прямое вычисление кривизны по радиусу соприкасающейся окружности
%     с просмотром графиков
n=length(Dis)-2;Kr=zeros(1,n);
for k=1:n;
  x1=Dis(k);x2=Dis(k+1);x3=Dis(k+2);y1=Nz(k);y2=Nz(k+1);y3=Nz(k+2);
  A=[x1-x2 y1-y2;x2-x3 y2-y3];b=[x1^2-x2^2+y1^2-y2^2;x2^2-x3^2+y2^2-y3^2]*0.5;
  ab=A\b;r=sqrt((x3-ab(1))^2+(y3-ab(2))^2);Kr(k)=1/r;
  aaa=max([ab(1)-r Dis(end)]);bbb=min([ab(1)+r Dis(1)]);
  X=linspace(aaa,bbb,51);Y=ab(2)+sqrt(r^2-(X-ab(1)).^2);
  if Riss==1;figure(102);plot(Dis,Nz,'.-');hold on;plot(X,Y,'r');pause;else end
end
if Riss==1;hold off
figure(101);plot(Dis(1:n),Kr,'.-');end
