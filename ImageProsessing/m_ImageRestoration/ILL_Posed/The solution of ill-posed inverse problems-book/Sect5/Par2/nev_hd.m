function [F]=Nev_hd(T,K,B,fi,Tsig,esig,T_ep);

% e_sigma(T_2)
es=interp1(Tsig,esig,T);nna=find(isnan(es));
   if ~isempty(nna);T(nna)=1;es=interp1(Tsig,esig,T);end
F1=K*([es.*T.^4;flipud(es.*T.^4)]);
Be=interp1(T_ep,B,T);nna=find(isnan(Be));
   if ~isempty(nna);T(nna)=1;Be=interp1(T_ep,B,T);end
   F2=K*(fi.*[Be;flipud(Be)]);
   F=F1+F2;
