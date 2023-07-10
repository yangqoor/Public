function [Om,Dom]=Omega_GE(c,AA,U,delta,s,C);
global zadan
%ep=1e-8;
if zadan==1;[Om,Dom]=Omega_gen_entr(c,AA,U,delta,s);
   else [Om,Dom]=Omega_w12(c,AA,U,delta,s);end

