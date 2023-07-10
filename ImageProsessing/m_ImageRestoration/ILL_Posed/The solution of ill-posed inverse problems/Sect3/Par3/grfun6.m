function [G,Geq,GC,GCeq]=grfun6(x,H,y,r)
G=sum(x.*log(x))-r;GC=log(x)+1;
Geq=[];GCeq=[];