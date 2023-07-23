function g=neu_int_g7(u,s,x)
%g=85/7;

global a N3 N4 N7 
s7=linspace(0,1,N7);g=interp1(s7,a(N3+N4-1:end),s,'spline');
