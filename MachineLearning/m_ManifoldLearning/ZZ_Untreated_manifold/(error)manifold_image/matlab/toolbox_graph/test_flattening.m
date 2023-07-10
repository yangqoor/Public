% test for triangulation plotting
% (i.e. flattening of an disk-shaped 3D model)
%
%   Copyright (c) 2005 Gabriel Peyré


name = 'nefertiti.off';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% file loading
[vertex,face] = read_off(name);
if size(vertex,1)<size(vertex,2)
    vertex = vertex';
end
if size(face,1)<size(face,2)
    face = face';
end
A = triangulation2adjacency(face);

n = length(A);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% original model
clf;
subplot(2,2,1);
plot_mesh(vertex,face);
title('Original model');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% spectral graph drawing : use the eigenvectors of the laplacian
options.method = 'flattening';
options.laplacian = 'combinatorial'; 
xy = compute_parameterization(vertex,face, options);
subplot(2,2,2);
plot_graph(A,xy);
title('Combinatorial laplacian');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% same but use conformal laplacian
options.method = 'flattening';
options.laplacian = 'conformal'; 
xy = compute_parameterization(vertex,face, options);
subplot(2,2,3);
plot_graph(A,xy);
title('Conformal laplacian');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% use IsoMap
options.method = 'isomap';
xy = compute_parameterization(vertex,face, options);
subplot(2,2,4);
plot_graph(A,xy);
title('Isomap');


