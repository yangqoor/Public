function [G,gc]=OMN_con(z,x,t,H,rho,h,U,n,m,alfa,z1)

G=(norm(z-z1)^2*(h)+norm(diff(z-z1))^2/(h))-alfa^2;
gc=[];   
   
