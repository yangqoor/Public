% Course 4 - Graph computation

path(path, 'toolbox_dimreduc');
path(path, 'toolbox_dimreduc/toolbox/');
path(path, 'toolbox_dimreduc/data/');
path(path, 'toolbox_graph');

test_dataset= 1;
test_graph = 1;
test_dimensionreduc = 1;
test_imagelib = 1;

rep = 'images/tp4/raw/';
if ~exist(rep)
    mkdir(rep);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% display of the datasets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if test_dataset
    
name = 'scurve';
name = 'swissroll';
n = 3000; % number of points

[X,col] = load_points_set( name, n );

clf;
plot_scattered(X,col);
axis equal; axis off;
saveas(gcf, [rep name '-display.jpg'], 'jpg');
    
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% display of the datasets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if test_graph

name = 'swissroll';
name = 'scurve';

n = 800; % number of points
options.use_nntools = 0;
options.nn_nbr = 7; % number of nearest neighbor
[X,col] = load_points_set( name, n );

% compute NN graph
[D,A] = compute_nn_graph(X,options);

% display the graph
clf;
plot_graph(A,X, col);
axis tight; axis off;
saveas(gcf, [rep name '-graph.jpg'], 'jpg');

% compute some geodesic distance
[tmp,start_point] = min( abs(col(:)-mean(col(:)))); % starting point
W = D; D(D==Inf) = 0; % weight on the graph
[d,S] = perform_dijkstra(D, start_point);

clf;
hold on;
plot_scattered(X, d);
h = plot3(X(1,start_point), X(2,start_point), X(3,start_point), 'k.');
set(h, 'MarkerSize', 25);
axis tight; axis off;
hold off;
view(3)
saveas(gcf, [rep name '-dist.jpg'], 'jpg');
    
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% dimension reduction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if test_dimensionreduc
    
name = 'scurve';
name = 'swissroll';

    
n = 800; % number of points
options.use_nntools = 0;
[X,col] = load_points_set( name, n );

% dimension reduction using isomap
options.nn_nbr = 7;
xy = isomap(X,2, options);
clf;
plot_scattered(xy,col);
axis equal; axis off;
saveas(gcf, [rep name '-dred-isomap.jpg'], 'jpg');

% dimension reduction using PCA
[Y,xy] = pca(X,2);
clf;
plot_scattered(xy,col);
axis equal; axis off;
saveas(gcf, [rep name '-dred-pca.jpg'], 'jpg');

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% image library
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if test_imagelib
    % test for dimension reduction on images datasets

name = 'binaryalphadigs';
name = 'umist_cropped';
name = 'edges';
name = 'digits';
name = 'olivettifaces';
name = 'disks';
name = 'frey_rawface';


if strcmp(name, 'frey_rawface')
    options.nclass = 1:5;
    options.nbr = 2000;
else
    options.nbr = 1000;    
end

% Read database
M = load_images_dataset(name, options);
% subsample at random
n = 1000;
sel = randperm(size(M,3));
M = M(:,:,sel(1:n));

if strcmp(name, 'frey_rawface')
    M = permute(M,[2 1 3]);
end


%% turn it into a set of points
a = size(M,1);
b = size(M,2);
n = size(M,3);
X = reshape(M, a*b, n);

%% display the data set
p = [20 20];
p = min( p, ceil([sqrt(n) sqrt(n)]) );
s=0;
m = [size(M,1) size(M,2)];
p = min( p, round([2000 2000]./m) );
A = zeros(p.*m);
for kx=1:p(1)
    for ky=1:p(2)
        s = s+1;
        if s<n
            selx = (kx-1)*m(1)+1:kx*m(1);
            sely = (ky-1)*m(2)+1:ky*m(2);
            A(selx,sely) = M(:,:,s);
        end
    end
end

clf;
hold on;
q = size(A,1);
r = size(A,2);
imagesc( [0,r-1]+0.5,[0,q-1]+0.5, A );
colormap gray(256);
axis tight; axis square; axis off;
axis xy;
for x=0:b:q
    line([x x], [0 r]);
end
for x=0:a:q
    line([0 r], [x x]);
end
hold off;
axis ij
saveas(gcf, [rep name '-dataset.jpg'], 'jpg');

%% perform isomap
options.nn_nbr = 7;
options.use_nntools = 0;
xy = isomap(X,2, options);

k = 30;
clf;
plot_flattened_dataset(xy,M,k);
saveas(gcf, [rep name '-isomap.jpg'], 'jpg');

%% perform pca
[tmp,xy] = pca(X,2);
clf;
plot_flattened_dataset(xy,M,k);
saveas(gcf, [rep name '-pca.jpg'], 'jpg');




end
    