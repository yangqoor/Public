% usps 38 data set;
clc;
close;
clear;
load('usps38.mat'); 

% average squared distance
b = stdv(data); 

% construct an rbf kernel in the form of exp(-||x||^2/b);
kernel = struct('type', 'rbf', 'para', b); 

%% construct a degree-2 polynomial kernel
% kernel = struct('type', 'pol', 'para', 2); 

% number of landmark points, the larger the slower but more accurate
m = 10; 

% kernel PCA
V = INys_KPCA(data, kernel, m); 
subplot(2,2,1), plot(V(:,1),V(:,2),'b.');
title('KPCA embedding');

% sepctral embedding
V = INys_SpectrEmbed(data, kernel, m);
subplot(2,2,2), plot(V(:,2),V(:,3),'b.');
title('Spectral embedding (Laplacian Eigenmap)');

% multidimensional scaling
V = INys_MDS(data, m); 
subplot(2,2,3), plot(V(:,1),V(:,2),'b.');
title('MDS embedding');


%% compare Nystrom and Improved Nystrom method in approximating the kernel  matrix (rbf kernel)

% RBF kernel with kernel width b
K = exp(-sqdist(data', data')/b);

for i = 1:10;
    m = i*10;
    Kt1 = INys(kernel,data, m, 'k');
    Kt2 = INys(kernel,data, m, 'r');
    err1(i) = norm(K - Kt1, 'fro');
    err2(i) = norm(K - Kt2, 'fro');
end;
subplot(2,2,4),
plot((1:10)*10, err2,'bs','LineStyle','-');
hold on;plot((1:10)*10, err1,'ro','LineStyle','-');
xlabel('number of landmark points');
ylabel('approximation error of K');
legend('Nystrom','INystrom');    