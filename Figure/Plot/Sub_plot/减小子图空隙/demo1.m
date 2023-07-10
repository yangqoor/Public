type='tight';

tsubplot(2,2,1,type)
x=linspace(0,10);
y1=sin(x);
plot(x,y1,'LineWidth',1.5)
title('Subplot 1: sin(x)')

tsubplot(2,2,2,type)
y2=sin(2*x);
plot(x,y2,'LineWidth',1.5)
title('Subplot 2: sin(2x)')

tsubplot(2,2,3,type)
y2=sin(3*x);
plot(x,y2,'LineWidth',1.5)
title('Subplot 3: sin(3x)')

tsubplot(2,2,4,type)
y3=sin(4*x);
plot(x,y3,'LineWidth',1.5)
title('Subplot 4: sin(4x)') 