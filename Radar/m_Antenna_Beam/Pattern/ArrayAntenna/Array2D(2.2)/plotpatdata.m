% plot data from plotdat file
clear
load patdata;
theta=patdata(1,:);
phi=patdata(2,:);
Er=patdata(3,:);
Ei=patdata(4,:);
Emag=sqrt(Er.^2+Ei.^2);
Efaz=atan2(Ei,Er);
N=length(Efaz);
for n=1:N
    Bipol(n)=1;
    if Efaz(n)<0, Bipol(n)=-1; end
end

plot(theta,-Emag.*Bipol)