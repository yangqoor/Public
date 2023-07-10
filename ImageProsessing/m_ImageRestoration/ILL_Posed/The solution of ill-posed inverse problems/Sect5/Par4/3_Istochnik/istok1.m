function f=istok1(p,t,u,time);

global xx yy XX YY a

np=size(p,2);nt=size(t,2);

[t1,tn,t2,t3]=tri2grid(p,t,zeros(np,1),xx,yy);
f=zeros(1,nt);

if ~isnan(tn)
  f(tn)=rh1(XX,YY,a);% Формула для источника
end
