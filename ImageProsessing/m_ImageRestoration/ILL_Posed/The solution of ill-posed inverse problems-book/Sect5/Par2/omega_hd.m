function [Om,gom]=Omega_hd(T,K,B,fi,Tsig,esig,T_ep,C);
es=interp1(Tsig,esig,T);nna=find(isnan(es));
   if ~isempty(nna);T(nna)=1;es=interp1(Tsig,esig,T);end

Om=sum([es.*T.^4;flipud(es.*T.^4)])/(2*length(T)-1)-C;

gom=[];