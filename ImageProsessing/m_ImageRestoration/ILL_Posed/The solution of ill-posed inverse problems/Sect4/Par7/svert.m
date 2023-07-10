function [ff]=svert(x,xx)
z=(1/2*log(2+x.^2-2*x)-x.*atan(x-1)-1/2*log(1+x.^2)+x.*atan(x));
ff=z./(1+(xx-x).^2);
  