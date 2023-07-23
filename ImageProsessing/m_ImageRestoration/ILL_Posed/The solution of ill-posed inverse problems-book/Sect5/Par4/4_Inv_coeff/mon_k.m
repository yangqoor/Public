function [F,G]=mon_k(ku,n,x,A,B,uu,F,tt,U0,alf,re)
%u=uu(uu<=max(max(UU)));kkk=ku(uu<=max(max(UU)));
%kkk=ku(uu<=max(max(U0)));
kkk=ku(uu<=0.25);
if re==2;F=-diff(diff(kkk));elseif re==1; F=-(diff(kkk));
else F=-[diff(kkk) diff(diff(kkk))];end
   G=[];
