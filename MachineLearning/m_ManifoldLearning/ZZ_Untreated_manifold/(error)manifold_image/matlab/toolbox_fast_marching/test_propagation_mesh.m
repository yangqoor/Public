% test for front propagation on 3D meshes
%
%   Copyright (c) 2007 Gabriel Peyre

path(path, 'toolbox/');


disp('Loading mesh.');
% [vertex,faces] = gen_base_mesh('ico',4);

path(path, '../toolbox_graph_data/');
rep = '../toolbox_graph_data/off/';
rep = '';
name = 'fandisk.off';
name = 'beetle.off';
name = 'nefertiti.off';
[vertex,faces] = read_mesh([rep name]);
% plot_mesh(vertex, faces);

nverts = max(size(vertex));
nstart = 8;
start_points = [1 round(nverts/2)];
start_points = floor(rand(nstart,1)*nverts)+1;
end_points = [round(nverts/2)];
end_points = [];
start_points = start_points(:);
options.end_points = end_points(:);

disp('Performing propagation.');
[D,S,Q] = perform_fast_marching_mesh(vertex, faces, start_points, options);

col = D;
col(col==Inf) = 0;
options.face_vertex_color = col;
clf;
hold on;
plot_mesh(vertex, faces, options);
h = plot3(vertex(1,start_points),vertex(2,start_points), vertex(3,start_points), 'k.');
set(h, 'MarkerSize', 25);
hold off;
colormap jet(256);

shading interp;
lighting none;

return;

col = Q;
options.face_vertex_color = col;
plot_mesh(vertex, faces, options);
colormap jet(256);

return;
[D,S,Q] = perform_front_propagation_mesh(vertex, faces-1, W,start_points-1,end_points-1, nb_iter_max,H,L);
Q = Q+1;