function [f,df]=hill_obj(x,dims,ii,dd,pars);
% 
% computes the objective function and gradient of the non-convex formulation of MVU. 
%
% copyright by Kilian Q. Weinberger, 2006
%

X=reshape(x,dims);
[df,f]=computegr(X,ii(:,1),ii(:,2),dd);
df=df(:).*8;

if(pars.eta>0) % incorporate the trace term
  df=df-pars.eta.*x;
  f=f-pars.eta.*sum(sum(x.^2));
end;

