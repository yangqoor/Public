%5
function j=DG(x,Obs,t)
LengthTime=length(t);

j=sum((Obs-x(1)*exp(-x(2).*t).*cos(2*pi*x(3).*t)).^2);


