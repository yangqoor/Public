% demo1

t=0:.01:2*pi;
X=cos(t);
Y=sin(t);

plot(X,Y,'LineWidth',2);
hold on;axis equal
shadowFill(X,Y,pi/3,80);