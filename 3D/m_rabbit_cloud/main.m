tic;
mm=load('bunny3.txt');

%mm=POINTS';
x=mm(:,1);
y=mm(:,2);
z=mm(:,3);

N=length(x);
%m=N*N-N;
m=(N-1)*(N-1);
 s=zeros(m,3);
j=1;
for i=1:N-1
   
     for k=[1:i-1,i+1:N]
   % S(i,j)=(x(i)-x(j))*(x(i)-x(j))+(y(i)-y(j))*(y(i)-y(j))+(z(i)-z(j))*(z(i)-z(j));
    s(j,1)=i; s(j,2)=k; s(j,3)=-sqrt(sum((x(i)-x(k)).^2+(y(i)-y(k)).^2+(z(i)-z(k)).^2));
    j=j+1;   
   
     end  
end

p=median(s(:,3)); % Set preference to median similarity
 [idx,netsim,dpsim,expref]=apcluster(s,p,'500');
fprintf('Number of clusters: %d\n',length(unique(idx)));
 fprintf('Fitness (net similarity): %f\n',netsim);
 figure; % Make a figures showing the data and the clusters
%for i=unique(idx)'
  %ii=find(idx==i); 
  %h=plot3(x(ii),y(ii),z(ii),'.'); hold on;
  
  % col=rand(1,3); set(h,'Color',col,'MarkerFaceColor',col);
  %xi1=x(i)*ones(size(ii)); xi2=y(i)*ones(size(ii)); 
  %line([x(ii,1),xi1]',[x(ii,2),xi2]','Color',col);
 %end;
 %axis equal tight;
 
d=unique(idx);
len=length(d);
 for i=1:len
 xx(i)=x(d(i));
yy(i)=y(d(i));
zz(i)=z(d(i));
 end
 savefile = 'bunny33.mat';
 p=zeros(len,3);
p2=[xx' yy' zz'];
save(savefile, 'p');
p=[x y z];
[t1]=MyCrust(p);
[t2]=MyCrust(p2);
%% figure(1)
figure(1);
set(gcf,'position',[0,0,1280,800]);
subplot(2,2,1)
hold on
axis equal
title('Initial Points Cloud','fontsize',14)
plot3(x,y,z,'g.')
view(0,90);
%% figure(2)
figure(1)
subplot(2,2,2)
hold on
title('Output Points Cloud','fontsize',14)
axis equal
h=plot3(xx,yy,zz,'.');
view(0,790);
 %% plot of the output triangulation
figure(1)
subplot(2,2,3)
hold on
title('Output Triangulation1','fontsize',14)
axis equal
trisurf(t1,x,y,z,'facecolor','c','edgecolor','b')%plot della superficie trattata
view(0,90);
  %% plot of the output triangulation
figure(1)
subplot(2,2,4)
hold on
title('Output Triangulation2','fontsize',14)
axis equal
trisurf(t2,xx,yy,zz,'facecolor','c','edgecolor','b')%plot della superficie trattata
view(0,90);
 
 
 
 
 

toc;
