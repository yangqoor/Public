% demo2

t=0:.01:2*pi;
y=sin(t); 

plot(t,y,'LineWidth',2);
hold on;axis equal
shadowFill(t,y,pi/4,80);