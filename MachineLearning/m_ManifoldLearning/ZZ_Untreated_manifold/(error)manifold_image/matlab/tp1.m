% Course n?1 for "A Matlab Tour of Fast Marching Methods"


% first set up path
path(path, 'toolbox_fast_marching/');
path(path, 'toolbox_fast_marching/data/');
path(path, 'toolbox_fast_marching/toolbox/');


rep = 'images/raw/';
if ~exist(rep)
    mkdir(rep);
end

test_2d = 0;
test_3d = 0;
test_sampling = 0;
test_heuristic = 0;
test_voronoi = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2D shortest paths
if test_2d

n = 200;
name = 'road2';
name = 'mountain';
name = 'cavern';


W = imread([name '.png']);
W = rescale( double(W) );
W = W + 0.01;    
[start_points,end_points] = pick_start_end_point(W);

% options.nb_iter_max = Inf;
% options.Tmax = sum(size(W));
options.end_points = end_points;
disp('Performing front propagation.');
[D,S] = perform_fast_marching_2d(W, start_points, options);
disp('Extracting path.');

p = extract_path_2d(D,end_points, options);


clf;
D1 = D; I = find(isinf(D)); J = find(~isinf(D)); 
D1(I) = max(D(J));
imagesc(D1'); axis image; axis off;
axis xy;
colormap jet(256);
saveas(gcf, [rep name '-dist-function.jpg'], 'jpg');

clf;
plot_fast_marching_2d(W,S,p,start_points,end_points);
colormap jet(256);
saveas(gcf, [rep name '-shortest-path-2d.jpg'], 'jpg');

clf;
contour(D1',50); axis image; axis off; axis xy;
colormap jet(256);
saveas(gcf, [rep name '-dist-function-contour.jpg'], 'jpg');

% essayer avec d'autres images : 'road2.png' 'moutain.png' 

% essayer avec d'autres type d'?nergies (gradient filtr?s).

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Voronoi cels
if test_voronoi

n = 300;
name = 'constant';
name = 'mountain';

[M,W] = load_potential_map(name, n);
if strcmp(name, 'mountain')
    W = rescale(W,0.05,1);
end

m = 50; % number of center points
if ~exist('start_points') || size(start_points,2)~=m
start_points = floor( rand(2,m)*(n-1) ) +1;
start_points = unique(start_points', 'rows')';
end


disp('Performing front propagation.');
[D,Z,Q] = perform_fast_marching_2d(W, start_points);

clf;
hold on;
imagesc(D'); axis image; axis off;
plot(start_points(1,:), start_points(2,:), '.');
hold off;
axis xy;
colormap gray(256);
saveas(gcf, [rep name '-voronoi-dist.jpg'], 'jpg');


faces = compute_voronoi_triangulation(Q);
hold on;
sel = randperm(max(Q(:)));
imagesc(sel(Q)'); axis image; axis off;
plot(start_points(1,:), start_points(2,:), 'b.', 'MarkerSize', 20);
plot_edges(compute_edges(faces), start_points, 'k');
hold off;
axis tight; axis image; axis off;
colormap jet(256);
saveas(gcf, [rep name '-voronoi-triangulation.jpg'], 'jpg');



end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3D shortest paths

if test_3d

n = 60;
% gaussian weight (path will avoid center of the cube)
x = -1:2/(n-1):1;
[X,Y,Z] = meshgrid(x,x,x);
sigma = 0.3;
W = 1./(1 + exp( -(X.^2+Y.^2+Z.^2)/sigma^2 ) );

k = 18;
start_points = [n-k;k;k];
end_points = [k;n-k;n-k];

options.nb_iter_max = Inf;
options.end_points = end_points;

[D,S] = perform_fast_marching_3d(W, start_points, options);
p = extract_path_3d(D,end_points);

% draw the path
plot_fast_marching_3d(D,S,p,start_points,end_points);
saveas(gcf, [rep 'shortest-path-3d.jpg'], 'jpg');

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% farthest point sampling

if test_sampling
    
% test for farthest point sampling


n = 300;

name = 'bump';
name = 'gaussian';
name = 'road2';
name = 'mountain';

[M,W] = load_potential_map(name, n);

% plot sampling location
i = 0;
for nbr_landmarks = 50:50:300 
    i = i+1;
    disp('Perform farthest point sampling');
    landmark = farthest_point_sampling( W, [], nbr_landmarks );
    
    clf;
    hold on;
    imagesc(M');
    plot(landmark(1,:), landmark(2,:), 'b.', 'MarkerSize', 20);
    hold off;
    axis tight; axis image; axis off;
    colormap gray(256);
    saveas(gcf, [rep 'farthest-sampling-' num2str(nbr_landmarks) '.jpg'], 'jpg');
    
    
    [D,Z,Q] = perform_fast_marching_2d(W, landmark);
    faces = compute_voronoi_triangulation(Q);
    hold on;
    imagesc(M'); axis image; axis off;
    plot(landmark(1,:), landmark(2,:), 'b.', 'MarkerSize', 20);
    plot_edges(compute_edges(faces), landmark, 'k');
    hold off;
    axis tight; axis image; axis off;
    colormap gray(256);
    saveas(gcf, [rep name '-sampling-triangulation-' num2str(nbr_landmarks) '.jpg'], 'jpg');
end
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% heuristic computation

if test_heuristic
    
n = 200;
name = 'cavern';
name = 'mountain';
name = 'road2';


weight = 0.9;

W = imread([name '.png']);
W = rescale( double(W) );
W = W + 0.01;    

% [start_points,end_points] = pick_start_end_point(W);

% compute heuristic
[H,S] = perform_fast_marching_2d(W, end_points);

% options.nb_iter_max = Inf;
options.end_points = end_points;
disp('Performing front propagation.');
[D,S] = perform_fast_marching_2d(W, start_points, options, H*weight);
disp('Extracting path.');
p = extract_path_2d(D,end_points, options);

clf;
plot_fast_marching_2d(W,S,p,start_points,end_points);
colormap jet(256);
saveas(gcf, [rep name '-heuristic' num2str(weight) '.jpg'], 'jpg');

    
end
