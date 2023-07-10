% Course nç3 - Mesh Processing


% first set up path
path(path, 'toolbox_graph/');
path(path, 'toolbox_graph/off');

rep = 'images/tp3/raw/';
if ~exist(rep)
    mkdir(rep);
end

test_laplacian = 1;
test_flattening = 0;
test_parameterization = 0;
test_mesh = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% mesh loading and displaying
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if test_mesh || test_laplacian
    
%% test for mesh loading and display
name = 'mushroom';
name = 'venus';
name = 'sphere';
name = 'L1';

if strcmp(name, 'sphere') || strcmp(name, 'L1')
    for j=0:3
        [vertex,face] = gen_base_mesh(name, j);
        clf;
        plot_mesh(vertex,face);
        saveas(gcf, [rep name '-subd-' num2str(j) '.jpg'], 'jpg');
    end
else
    % special subdivision scheme
    [vertex,face] = read_mesh([name '.off']);
end

clf;
plot_mesh(vertex,face);
saveas(gcf, [rep name '-mesh-display.jpg'], 'jpg');

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% laplacian
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if test_laplacian

%% combinatorial laplacian computation
A = triangulation2adjacency(face);
lap = compute_combinatorial_laplacian(A);

%% Performing SVD.
[U,S,V] = svd(lap);

%% Displaying some eigenvectors
nface = size(face,1);
nvert = max(max(face));
p = 3;
clf;
for i=1:p^2
    num = 14*(i-1)+1;
    c = U(:,nvert-num);
    % rescale c
    options.face_vertex_color = rescale(c, 0,255);
    clf;
    plot_mesh(vertex,face, options);
    str = sprintf('Eigenv. nÁ%d', num);
    title(str);
    saveas(gcf, [rep name '-eigv-' num2str(i) '.jpg'], 'jpg');
end

%% perform spectral mesh compression
if size(vertex,2)==3
    vertex = vertex';
end
p = 3;
nbr_max_keep = 8; % maximum number of percent of kepts coefficients
clf;
for i=1:p^2
    keep = 1+round(i*nbr_max_keep/p^2); % number of percents of coefficients kept
    vertex2 = (U'*vertex')'; % projection of the vector in the laplacian basis
    % set threshold
    vnorm = sum(vertex2.^2, 1);
    vnorms = sort(vnorm); vnorms = vnorms(end:-1:1);
    thresh = vnorms( round(keep/100*nvert) );
    % remove small coefs
    vertex2 = vertex2 .* repmat( vnorm>=thresh, [3 1] ); 
    % reconstruction
    vertex2 = (U*vertex2')';
    % display
    clf;
    plot_mesh(vertex2,face);
    str = [num2str(keep), '% of the coefficients'];
    title(str);
    saveas(gcf, [rep name '-compress-' num2str(i) '.jpg'], 'jpg');
end

end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Spectral Flattening
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if test_flattening
    
%% load the mesh
name = 'nefertiti';
[vertex,face] = read_mesh([name '.off']);


A = triangulation2adjacency(face);
n = length(A);


%% original model
clf;
plot_mesh(vertex,face);
saveas(gcf, [rep name '-original.jpg'], 'jpg');


%% Combinatorial Laplacian
xy = perform_spectral_embedding(2,A);
% display
gplot(A,xy,'k.-');
axis tight; axis square; axis off;
title('Combinatorial laplacian');
saveas(gcf, [rep name '-flat-combi.jpg'], 'jpg');

%% Conformal laplacian
xy = perform_spectral_embedding(2,A,vertex,face);
% display
gplot(A,xy,'k.-');
axis tight; axis square; axis off;
title('Conformal laplacian');
saveas(gcf, [rep name '-flat-confo.jpg'], 'jpg');

%% IsoMap
xy = perform_spectral_embedding(2,A,vertex);
% display
gplot(A,xy,'k.-');
axis tight; axis square; axis off;
title('Isomap');
saveas(gcf, [rep name '-flat-isomap.jpg'], 'jpg');

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Spectral Parameterization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if test_parameterization  
    
   
name = 'mannequin';
name = 'nefertiti';

[vertex,face] = read_mesh([name '.off']);
A = triangulation2adjacency(face);

% precompute 1-ring
ring = compute_1_ring(face);


boundary_types = {'circle','square','triangle'};
nbound = length(boundary_types);
lap_types = {'combinatorial','conformal'};
nlap = length(lap_types);
    

kk = 0;
for l = lap_types
k = 0;
for b = boundary_types
    kk = kk+1;
    k = k+1;
    
    boundary_type = cell2mat(b);
    lap_type = cell2mat(l);
    
    k = k+1;
    str = sprintf('%s laplacian, %s boundary', lap_type, boundary_type);
    disp(['Computing parameterization : ', str, '.']);
    xy = compute_parametrization(vertex,face,lap_type,boundary_type,ring);

%    subplot(nlap,nbound,kk);
    clf;
    gplot(A,xy,'k.-');
    axis tight;
    axis square;
    axis off;
    str = sprintf('%s boundary, %s laplacian', boundary_type, lap_type);
    title(str); 
    saveas(gcf, [rep name '-param-' boundary_type(1) lap_type(1:4) '.jpg'], 'jpg');
end
end

    
end

