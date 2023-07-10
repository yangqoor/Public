echo on;


% Unfolding the swiss roll
N=10000; % number of data points sampled from swiss roll
rand('seed',0);
[x,col]=genswissroll(N,10,5);
x=x+rand(size(x))-0.5;  % add random noise
figure(2);clf;
figure(1);clf;
scat(x,3,col,'circles',1);
view(4,5);
box on;
set(gca,'FontSize',18);
title(['INPUT (N=10000, additive uniform noise)']);
drawnow;
DD=dissimilar(x,inf,10);

[ymvu,detmvu]=fastmvu(DD,2,'leigsdim',20,'eta',1e-02,'maxiter',500);
figure(2);clf;
subplot(2,1,1);
scat(ymvu,2,col,'circles',1);
set(gca,'FontSize',18);
title('OUTPUT Lap-Reg-MVU (before fine-tuning)');

subplot(2,1,2);
scat(detmvu.ymvuLap,2,col,'circles',1);
set(gca,'FontSize',18);
title('OUTPUT Lap-Reg-MVU (after fine-tuning)');
drawnow;


