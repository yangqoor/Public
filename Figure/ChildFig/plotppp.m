figure(1);
h2=axes('position',[0 0 1 1]);
axis(h2);
x2=0:pi/50:2*pi;
y2=sin(x2);
h3=plot(x2,y2,'b-');
h1=axes('position',[0.3 0.2 0.4 0.4]);
axis(h1);
x1=0:pi/50:2*pi;
y1=cos(x1);
h4=plot(x1,y1,'r-');
hold on
h=[h3; h4];
str=['大图中的曲线';'小图中的曲线'];
legend(h,str);