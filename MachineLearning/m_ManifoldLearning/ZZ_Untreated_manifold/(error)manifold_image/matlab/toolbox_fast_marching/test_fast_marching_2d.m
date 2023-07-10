% test for fast marching
%
%   Copyright (c) 2004 Gabriel Peyré

n = 200;
map_name = 'data/cavern.png';


[W, cm] = imread(map_name);
W = rescale( double(W) );
W = W + 0.01;    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pick starting point
[start_points,end_points] = pick_start_end_point(W);

options.nb_iter_max = Inf;
options.end_points = end_points;
options.Tmax = sum(size(W));
disp('Performing front propagation.');
[D,S] = perform_fast_marching_2d(W, start_points, options);
disp('Extracting path.');
tic;
path = extract_path_2d(D,end_points, options);
toc;

plot_fast_marching_2d(W,S,path,start_points,end_points);
colormap gray(256);