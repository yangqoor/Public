echo on;

% Demo 1: Unfolding the swiss roll
[x,col]=genswissroll(5000,0,4);
x=x+rand(size(x))-0.5;
figure(2);clf;
figure(1);clf;
scat(x,3,col,'circles',1);
set(gca,'FontSize',18);
title('INPUT (N=5000, additive uniform noise)');
drawnow;
DD=dissimilar(x,inf,10);
% if the second input to fastmvu is matrix containing the input vectors as columns, 
% it uses LLE for basis vectors
[y1lle,det1lle]=fastmvu(DD,2,'leigsdim',20,'eta',1e-02,'maxiter',500);
figure(2);clf;
subplot(2,1,1);
scat(y1lle,2,col,'circles',1);
set(gca,'FontSize',18);
title('OUTPUT LLE Basis');
drawnow;

subplot(2,1,2);
% if the second input to fastmvu is [], it uses the Graph Laplacian as
% basis vectors
[y1lap,det1lap]=fastmvu(DD,2,'leigsdim',20,'eta',1e-02,'maxiter',500);
scat(y1lap,2,col,'circles',1);
set(gca,'FontSize',18);
title('OUTPUT LAP Basis');
drawnow;


% Demo 2: Sensor Network Localization
% Press Enter to continue!
pause;
% generating random data set
x=load('uscities.txt');
N=size(x,2);

figure(3);
clf;
plot(x(1,:),x(2,:),'k.');
set(gca,'FontSize',18);
title('INPUT');
ax=axis;
drawnow;

% connecting data points within radius of 0.1 and corrupting it with 10% noise
D=dissimilar(x,0.05^2,30,0.1);

figure(4);
clf;
plot(x(1,:),x(2,:),'k.');
set(gca,'FontSize',18);
title('epsilon-GRAPH');
ax=axis;
hold on;
gplot(D,x');
drawnow;

% run fastmvu
[y,det]=fastmvu(D,[],2,'leigsdim',10,'eta',1e-04,'maxiter',1000);

% plot output
figure(5);
clf;
y(1,:)=y(1,:).*sign(y(1,445));
y(2,:)=y(2,:).*sign(y(2,445));
plot(y(1,:),y(2,:),'k.');
set(gca,'FontSize',18);
title('OUTPUT');
axis(ax);
