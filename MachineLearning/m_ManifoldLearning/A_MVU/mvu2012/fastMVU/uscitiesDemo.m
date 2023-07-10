echo on;

% generating random data set
x=load('uscities.txt');
N=size(x,2);

figure(1);
clf;
plot(x(1,:),x(2,:),'k.');
set(gca,'FontSize',18);
title('INPUT');
ax=axis;
drawnow;

% connecting data points within radius of 0.1 and corrupting it with 10% noise
D=dissimilar(x,0.05^2,20,0.1);

figure(2);
clf;
plot(x(1,:),x(2,:),'k.');
set(gca,'FontSize',18);
title('INPUT (epsilon-GRAPH)');
ax=axis;
hold on;
gplot(D,x');
drawnow;

% run fastmvu
[y,det]=fastmvu(D,2,'leigsdim',10,'eta',1e-04,'maxiter',500);

% plot output
figure(3);
clf;
yl(1,:)=det.ymvuLap(1,:).*sign(det.ymvuLap(1,445));
yl(2,:)=det.ymvuLap(2,:).*sign(det.ymvuLap(2,445));
plot(yl(1,:),yl(2,:),'k.');
set(gca,'FontSize',18);
title('OUTPUT (before fine-tuning)');
axis(ax);

figure(4);
clf;
y(1,:)=y(1,:).*sign(y(1,445));
y(2,:)=y(2,:).*sign(y(2,445));
plot(y(1,:),y(2,:),'k.');
set(gca,'FontSize',18);
title('OUTPUT');
axis(ax);
