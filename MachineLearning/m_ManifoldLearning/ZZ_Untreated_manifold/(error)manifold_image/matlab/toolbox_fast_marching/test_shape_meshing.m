% test for meshing the inside of an object

rep  = 'data/';
name = 'mm';
n = 220;
Ma = load_image([rep name],n-10);
% to avoid that the shape touches the boundary
M = zeros(n,n,3);
M(6:n-5,6:n-5,:) = Ma;

repimg = 'results/meshing/';
if ~exist(repimg)
    mkdir(repimg);
end


M1 = sum(M,3);
mask = 1-(M1==M1(1));
p = 200;


%% compute distance to boundary field
% compute boundary points
h = ones(3)/9;
H = perform_convolution(double(mask),h);
B = H>2/9 & H<1-2/9;
I = find(B);
[x,y] = ind2sub(size(M),I);
boundary = [x(:)';y(:)'];
% compute distance to boundary
[D,Z,Q] = perform_fast_marching_2d(ones(n), boundary);


use_adaptive = 1;
if use_adaptive
    R = 0.8;
    D1 = min(rescale(D),R);
    H = sqrt( R^2 - (D1-R).^2 ) * n;
    W = rescale( D, 0.1,1 );
else
    W = ones(n);
end



%% perform sampling using farthest point
L = zeros(n) - Inf;
I = find(mask); L(I) = Inf;
vertex = [n/2;n/2];
options.constraint_map = L;
vertex = farthest_point_sampling(W, vertex, p, options );

%% compute the associated triangulation
[D,Z,Q] = perform_fast_marching_2d(W, vertex, options);
faces = compute_voronoi_triangulation(Q, vertex);

%% display
clf;
hold on;
imagesc(rescale(M)); axis image; axis off;
plot(vertex(2,:), vertex(1,:), 'b.', 'MarkerSize', 20);
plot_edges(compute_edges(faces), vertex(2:-1:1,:), 'r');
hold off;
axis tight; axis image; axis off;
colormap gray(256);
axis ij;

str = [name '-mesh-' num2str(p)];
if use_adaptive
    str = [str '-adaptive'];
end
saveas(gcf, [repimg str '.png'], 'png');