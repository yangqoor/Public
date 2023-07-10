t=linspace(0,2*pi,200);
X=cos(t).*1.8;
Y=sin(t).*1.3;
hold on
fill(X,Y,[102,194,165]./255,'EdgeColor',[102,194,165]./255);

theta=pi/6;
rotateMat=[cos(theta),-sin(theta);sin(theta),cos(theta)];
XY=rotateMat*([X;Y].*.8);
X=XY(1,:);Y=XY(2,:);
fill(X+1,Y+1.3,[252,140,98]./255,'EdgeColor',[252,140,98]./255);
legend