% nanContourfDemo
Z=peaks(500);
[X,Y]=meshgrid(1:size(Z,2),1:size(Z,1));
Z(Y>sin(X/40).*100+350)=nan;
contourf(X,Y,Z,20,'EdgeColor','none')