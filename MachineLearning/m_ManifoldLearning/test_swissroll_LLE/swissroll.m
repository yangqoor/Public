% SWISS ROLL DATASET

  N=8000;
  K=12;
  d=2; 

clf; colordef none; colormap jet; set(gcf,'Position',[200,400,620,200]);

% PLOT TRUE MANIFOLD
  tt0 = (3*pi/2)*(1+2*[0:0.02:1]); hh = [0:0.125:1]*30;%��������
  xx = (tt0.*cos(tt0))'*ones(size(hh));
  yy = ones(size(tt0))'*hh;
  zz = (tt0.*sin(tt0))'*ones(size(hh));
  cc = tt0'*ones(size(hh));

  subplot(1,3,1); cla;
  surf(xx,yy,zz,cc);%�����յ���ά����ͼ
  view([12 20]); grid off; axis off; hold on;%��άͼ�ӽ�
  lnx=-5*[3,3,3;3,-4,3]; lny=[0,0,0;32,0,0]; lnz=-5*[3,3,3;3,3,-3];
  lnh=line(lnx,lny,lnz);
  set(lnh,'Color',[1,1,1],'LineWidth',2,'LineStyle','-','Clipping','off');
  axis([-15,20,0,32,-15,15]);

% GENERATE SAMPLED DATA
  tt = (3*pi/2)*(1+2*rand(1,N));  height = 21*rand(1,N);%���������㣬����tt�������
  X = [tt.*cos(tt); height; tt.*sin(tt)];%X����ά����

% SCATTERPLOT OF SAMPLED DATA
  subplot(1,3,2); cla;%������ͼ 
  scatter3(X(1,:),X(2,:),X(3,:),12,tt,'+');%ɢ��ͼ
  view([12 20]); grid off; axis off; hold on;%�趨3Dͼ�ι۲��
  lnh=line(lnx,lny,lnz);%������
  set(lnh,'Color',[1,1,1],'LineWidth',2,'LineStyle','-','Clipping','off');
  axis([-15,20,0,32,-15,15]);%��Ŀ���
  drawnow;%��Ļˢ��

% RUN LLE ALGORITHM
Y=lle(X,K,d);

% SCATTERPLOT OF EMBEDDING
  subplot(1,3,3); cla   %cla�����ǰ��
  scatter(Y(1,:),Y(2,:),12,tt,'+');  %scatterɢ��ͼ
  grid off;%������������
  set(gca,'XTick',[]); set(gca,'YTick',[]); %������������



