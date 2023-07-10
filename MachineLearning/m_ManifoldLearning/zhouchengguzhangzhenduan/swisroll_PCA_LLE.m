%生成swisroll
N=3000;
x=rand(1,N);
y=rand(1,N);
X = zeros(3,N);
v = 3*pi/2 * (1 + 2*x');
col=x;
X(2,:) = 21 * y';
X(1,:) = cos( v ) .* v;
X(3,:) = sin( v ) .* v;
scatter3(X(1,:),X(2,:),X(3,:),12,col);
%plot_scattered(X,col);

% %使用方法PCA
 [Y,xy] = pca(X,2);
 figure;
 plot_scattered(xy,col);
 title('pca');
 axis equal; 

%使用方法lle
y = lle(X,30,2);
figure;
plot_scattered(y,col);
title('lle');
axis equal; 
