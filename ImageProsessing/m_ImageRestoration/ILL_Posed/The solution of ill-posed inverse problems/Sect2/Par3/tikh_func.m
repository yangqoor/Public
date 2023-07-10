function [F,G]=Tikh_func(c,AA,U,delta,s,alf)
global zadan
%alf=1e-4;
UU=AA*c;
if zadan==1;[Om,Dom]=Omega_gen_entr(c,AA,U,delta,s);
   else [Om,Dom]=Omega_w12(c,AA,U,delta,s);end
F=(norm(UU-U)/norm(U))^2+alf*(Om);
%
G=[];
