%生成scurve
N=3000;
t=pi*(1.5*rand(1,N/2)-1);
s=5*rand(1,N);
col=[t,t];
X=[[cos(t),-cos(t)];s;[sin(t),2-sin(t)]];
scatter3(X(1,:),X(2,:),X(3,:),12,col);
%plot_scattered(X,col);
%{
%使用方法PCA
[Y,xy] = pca(X,2);
figure;
plot_scattered(xy,col);
title('pca');
axis equal; 

%使用方法lle
y = lle(X,12,2);
figure;
plot_scattered(y,col);
title('lle');
axis equal; 
%}
xy = isomap(X,2) ;
figure;
plot_scattered(xy,col);
axis equal;