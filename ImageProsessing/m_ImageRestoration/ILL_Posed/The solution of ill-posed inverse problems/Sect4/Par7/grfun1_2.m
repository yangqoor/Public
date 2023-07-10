function [gf,gf1,GC,GC1]=grfun1_2(x,H,y,r,DEL)
% Для IST_OMN1

gf=norm(H*x-y)^2-DEL^2;
GC=2*(H'*H*x-H'*y);
gf1=[];GC1=[];