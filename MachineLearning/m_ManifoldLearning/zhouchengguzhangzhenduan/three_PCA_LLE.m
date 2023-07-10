% name = 'scurve';
% name = 'swissroll';
name='swisshole';

    
n = 2000; % number of points
options.use_nntools = 0;
[X,col] = load_points_set( name, n );
plot_scattered(X,col);

% % dimension reduction using isomap
% options.nn_nbr = 7;
% xy = isomap(X,2, options);
% figure;
% plot_scattered(xy,col);
% title('isomap');
% axis equal; %axis off;

% dimension reduction using PCA
[Y,xy] = pca(X,2);
figure;
plot_scattered(xy,col);
title('pca');
axis equal; %axis off;

y = lle(X,12,2);
figure;
plot_scattered(y,col);
title('lle');
axis equal; %axis off;
