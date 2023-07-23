function [du1,du6]=calcflux(s,p,t,u,u_ext);
%[ux,uy]=pdegrad(p,t,u);% градиент решения
[nx,ny]=normal_circle(s);
h=0.08;
for ii=1:length(s);
   [x1,y1]=reactg(1,s(ii));%du1(ii)=tri2grid(p,t,ux,x1,y1);
   dux1(ii)=tri2grid(p,t,u,x1-h,y1);
   [x6,y6]=reactg(6,s(ii));%dux6(ii)=tri2grid(p,t,ux,x6,y6);
   dux6(ii)=tri2grid(p,t,u,x6-h*nx(ii),y6-h*ny(ii));
   %duy6(ii)=tri2grid(p,t,uy,x6,y6);
end
%du6=dux6.*nx+duy6.*ny;
du1=-(u_ext-dux1)/h;du6=-(u_ext-dux6)/h;
%  Если интерполяция дает NaN:
jj=find(~isnan(du6));Du7=interp1(s(jj),du6(jj),s);du6=Du7;