% SWISS ROLL DATASET

  N=8000;
  K=12;
  d=2; 

clf; colordef none; colormap jet; set(gcf,'Position',[200,400,620,200]);

% PLOT TRUE MANIFOLD
  tt0 = (3*pi/2)*(1+2*[0:0.02:1]); hh = [0:0.125:1]*30;%绘制流形
  xx = (tt0.*cos(tt0))'*ones(size(hh));
  yy = ones(size(tt0))'*hh;
  zz = (tt0.*sin(tt0))'*ones(size(hh));
  cc = tt0'*ones(size(hh));

  subplot(1,3,1); cla;
  surf(xx,yy,zz,cc);%带光照的三维表面图
  view([12 20]); grid off; axis off; hold on;%三维图视角
  lnx=-5*[3,3,3;3,-4,3]; lny=[0,0,0;32,0,0]; lnz=-5*[3,3,3;3,3,-3];
  lnh=line(lnx,lny,lnz);
  set(lnh,'Color',[1,1,1],'LineWidth',2,'LineStyle','-','Clipping','off');
  axis([-15,20,0,32,-15,15]);

% GENERATE SAMPLED DATA
  tt = (3*pi/2)*(1+2*rand(1,N));  height = 21*rand(1,N);%创建样本点，设置tt这个变量
  X = [tt.*cos(tt); height; tt.*sin(tt)];%X的三维坐标

% SCATTERPLOT OF SAMPLED DATA
  subplot(1,3,2); cla;%绘制子图 
  scatter3(X(1,:),X(2,:),X(3,:),12,tt,'+');%散点图
  view([12 20]); grid off; axis off; hold on;%设定3D图形观测点
  lnh=line(lnx,lny,lnz);%创建线
  set(lnh,'Color',[1,1,1],'LineWidth',2,'LineStyle','-','Clipping','off');
  axis([-15,20,0,32,-15,15]);%轴的控制
  drawnow;%屏幕刷新

% RUN LLE ALGORITHM
Y=lle(X,K,d);

% SCATTERPLOT OF EMBEDDING
  subplot(1,3,3); cla   %cla清除当前轴
  scatter(Y(1,:),Y(2,:),12,tt,'+');  %scatter散点图
  grid off;%画坐标网格线
  set(gca,'XTick',[]); set(gca,'YTick',[]); %建立对象特性



