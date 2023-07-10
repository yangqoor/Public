function [gf,gf1,GC,GC1]=grfun1_3(z,A,u,ze,rE,DLL,h)
%  Äëÿ Auxil1
C=1.;
gf=[norm(z)^2*h+norm(diff(z))^2/h-C*rE^2;norm(A*z-u)^2-DLL^2];
GC=[2*z 2*(A'*A*z-A'*u)];
gf1=[];GC1=[];

