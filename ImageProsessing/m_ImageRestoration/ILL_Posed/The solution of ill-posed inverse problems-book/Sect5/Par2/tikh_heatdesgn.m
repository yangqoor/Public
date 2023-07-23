function [F,G]=Tikh_heatdesgn(T,K,B,fi,Tsig,esig,T_ep,alf);

% e_sigma(T_2)
es=interp1(Tsig,esig,T);nna=find(isnan(es));
   if ~isempty(nna);T(nna)=1;es=interp1(Tsig,esig,T);end
F1=K*([es.*T.^4;flipud(es.*T.^4)]);
Be=interp1(T_ep,B,T);nna=find(isnan(Be));
   if ~isempty(nna);T(nna)=1;Be=interp1(T_ep,B,T);end
   F2=K*(fi.*[Be;flipud(Be)]);
   Om=sum([es.*T.^4;flipud(es.*T.^4)])/(2*length(T)-1);
   F0=norm(F1+F2-1)/norm(ones(2*length(T),1));
   F=alf*Om+F0^2;
   G=[];
if isnan(F);disp(' %%% error %%%');disp(['   F=' num2str(F)]);end
