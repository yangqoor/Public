function r=dir_ext_r1(s)

global gg u_ext
%s7=linspace(0,1,N7);r=interp1(s7,a(N-N7+1:end),s,'spline');
r=u_ext*gg;
