t=linspace(pi/100,4*pi,500);
y1=cos(t).^2;
y2=sin(t).^2./t;

hold on
area(y1)
area(y2)