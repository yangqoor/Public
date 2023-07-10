function g=neu_int_g3(u,s,x)
%g=85/7;
global a N3 N4 N7 
s3=linspace(0,1,N3);g=interp1(s3,a(1:N3),s,'spline');
