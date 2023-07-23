function g=neu_int_g4(u,s,x)
%g=85/7;
global a N3 N4 N7 
s4=linspace(0,1,N4);g=interp1(s4,a(N3:N3+N4-1),s,'spline');
