function [var]=Var1(z);
%var=sum(abs(z(2:end)-z(1:end-1)));
epsil=0.001;var=sum(dff(z(2:end)-z(1:end-1)));