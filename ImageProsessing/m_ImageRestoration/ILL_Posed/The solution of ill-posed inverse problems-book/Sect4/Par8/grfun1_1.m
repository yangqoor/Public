function [gf,gf1,GC,GC1]=grfun1_1(x,H,y,r,DEL)
% Для IST_OMN1
gf=sum(x.^2)-r^2;
GC=2*x;
gf1=[];GC1=[];