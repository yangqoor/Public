function [nx,ny]=normal_circle(s)
% ¬нешн€€ нормаль к сегменту є 7
for ii=1:length(s);
t=[1 0
0 1];
nth=100;
th=linspace(-1.5707963267948966,0,nth);
rr=t*[cos(th);sin(th)];
theta=pdearcl(th,rr,s(ii),0,1);
rr=t*[cos(theta);sin(theta)];
x(ii)=rr(1,:)+(0);
y(ii)=rr(2,:)+(0);
end
nx=x./sqrt(x.^2+y.^2);ny=y./sqrt(x.^2+y.^2);