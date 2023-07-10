function [G,Geq,GC,GCeq]=grfun4(x,H,y,r)
G=sum(x)-r;GC=ones(size(x));
Geq=[];GCeq=[];