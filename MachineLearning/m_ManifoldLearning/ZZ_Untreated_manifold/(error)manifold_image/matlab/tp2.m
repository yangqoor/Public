% Course n2 - Fast Marching on Triangulated Surfaces


% first set up pathÉèÖÃÂ·¾¶
path(path, 'toolbox_fast_marching/');
path(path, 'toolbox_graph/');
path(path, 'toolbox_fast_marching/toolbox/');
path(path, 'toolbox_graph/off/');


rep = 'images/tp2/';
if ~exist(rep)
    mkdir(rep);
end

test_distance = 0;
test_remeshing = 0;
test_bending = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% distance computation on 3D Mesh
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if test_distance
    
name = 'beetle';
name = 'david50kf';
name = 'skull';
name = 'fandisk';
name = 'elephant';
[vertex,faces] = read_mesh([name '.off']);

nverts = max(size(vertex));
nstart = 8;

starters = floor(rand(50,1)*nverts)+1;

for nstart = [1 2 3 4 6 8 16 30 50]

clear options;
start_points = starters(1:nstart);
end_points = [];
start_points = start_points(:);
options.end_points = end_points(:);

if nstart==8
    a = 0;
    for nb = [100 200 400 800 1600 3200]
        a = a+1;
        options.nb_iter_max = nstart*nb;
        [D,S,Q] = perform_fast_marching_mesh(vertex, faces, start_points, options);

        col = D; col(col==Inf) = 0; clf;
        my_plot_mesh(vertex,faces,start_points,col,name);
        saveas(gcf, [rep name '-prop-' num2str(a) '.jpg'], 'jpg');
    end
end




options.nb_iter_max = Inf;
[D,S,Q] = perform_fast_marching_mesh(vertex, faces, start_points, options);


col = Q; col(col==Inf) = 0;
a = unique(col(:)); v = zeros(max(a),1); v(a) = 1:length(a);
col = v(col);
my_plot_mesh(vertex,faces,start_points,col,name);
saveas(gcf, [rep name '-segm-' num2str(nstart) '.jpg'], 'jpg');


col = D; col(col==Inf) = 0;
my_plot_mesh(vertex,faces,start_points,col,name);
saveas(gcf, [rep name '-dist-' num2str(nstart) '.jpg'], 'jpg');

end

end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% geodesic remeshing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if test_remeshing
    
name = 'beetle';
name = 'david50kf';
name = 'skull';
name = 'fandisk';
name = 'bunny';
name = 'hand-50kv';
[vertex,faces] = read_mesh([name '.off']);

nverts = max(size(vertex));


density = 'split';
density = 'grad';
density = 'cst';
switch density
    case 'cst'
        W = ones(nverts,1);
    case 'split'
        if strcmp(name,'bunny')
            v = rescale(vertex(1,:));
        else
            v = rescale(vertex(3,:));
        end
        W = rescale(v>0.5, 1, 3); W = W(:);
    case 'grad'
        v = rescale(-vertex(1,:),1,8);
        W = v(:);
end
options.W = W;

% plot sampling location
i = 0;
for nbr_landmarks = [100:200:500 800 1500]
    i = i+1;
    
    disp('Perform farthest point sampling.');
    options.verb = 0;
    landmark = farthest_point_sampling_mesh( vertex,faces, [], nbr_landmarks, options );
    
    % compute the associated triangulation
    [D,Z,Q] = perform_fast_marching_mesh(vertex, faces, landmark);
    [vertex_voronoi,faces_voronoi] = compute_voronoi_triangulation_mesh(Q,vertex,faces);

    
    % display
    col = D; col(col==Inf) = 0;
    options.face_vertex_color = col;
    my_plot_mesh(vertex,faces,landmark,col,name);
    
    str = [name '-' density '-sampl-' num2str(nbr_landmarks) ];
    saveas(gcf, [rep str '.jpg'], 'jpg');

       
    clf;
    plot_mesh(vertex_voronoi,faces_voronoi)
    shading faceted;
    lighting flat;
    if strcmp(name, 'beetle')
        view(-100,20);
    end
    if strcmp(name, 'david50kf')
    end
    if strcmp(name, 'skull')
        view(0,0);
    end
    if strcmp(name, 'fandisk')
        view(-172,-72);
    end
    camlight;
    
    str = [name '-' density  '-remesh-' num2str(nbr_landmarks,3)];
    saveas(gcf, [rep str '.jpg'], 'jpg');
end

end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% bending invariants
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if test_bending
    
name = 'david50kf';
name = 'skull';
name = 'fandisk';
name = 'elephant';
name = 'pig';
name = 'beetle';
[vertex,faces] = read_mesh([name '.off']);

nverts = max(size(vertex));
nstart = 8;

nlandmarks = 300;
landmarks = floor(rand(nlandmarks,1)*nverts)+1;
Dland = zeros(nverts,nlandmarks);

for i=1:nlandmarks
    fprintf('.');
    [d,S,Q] = perform_fast_marching_mesh(vertex, faces, landmarks(i));  
    Dland(:,i) = d(:);
end
fprintf('\n');

% perform isomap on the reduce set of points
D1 = Dland(landmarks,:);
D1 = (D1+D1')/2;
J = eye(nlandmarks) - ones(nlandmarks)/nlandmarks;
K = -1/2 * J*D1*J;
opt.disp = 0; 
[xy, val] = eigs(K, 3, 'LR', opt); 
xy = xy .* repmat(1./sqrt(diag(val))', [nlandmarks 1]);


% interpolation on the full set of points
% x = 1/2 * (L^T) * ( delta_n-delta_x )
xy1 = zeros(nverts,3);
deltan = mean(Dland,1);
for x=1:nverts
    deltax = Dland(x,:);
    xy1(x,:) = 1/2 * ( xy' * ( deltan-deltax )' )';
end
vertex1 = xy1';
    
end