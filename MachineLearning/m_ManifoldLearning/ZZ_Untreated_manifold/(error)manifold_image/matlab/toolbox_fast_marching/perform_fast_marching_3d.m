function [D,S] = perform_fast_marching_3d(W, start_points, options, H)

% perform_fast_marching_3d - launch the Fast Marching algorithm.
%
%   [D,S] = perform_fast_marching_3d(W, start_points, options, H)
%
%   'W' is the 3D weight matrix (the highest, the slowest the front will move).
%   'start_points' is a 3 x k array, start_points(:,i) is the ith starting point .
%
%   Optional:
%   - You can provide special conditions for stop in options :
%       'options.end_points' : stop when these points are reached
%       'options.nb_iter_max' : stop when a given number of iterations is
%          reached.
%   - You can provide an heuristic (typically that try to guess the distance
%       that remains from a given node to a given target).
%       This is an array of same size as W.
%
%   Copyright (c) 2004 Gabriel Peyré


if nargin<3
    options.null = 0;
end

if isfield(options,'end_points')
    end_points = options.end_points;
else
    end_points = [];
end

if isfield(options,'end_points')
    end_points = options.end_points;
else
    end_points = [];
end

if isfield(options,'verbose')
    verbose = options.verbose;
else
    verbose = 1;
end

if isfield(options,'nb_iter_max')
    nb_iter_max = options.nb_iter_max;
else
    nb_iter_max = 100;
end

nb_iter_max = min(nb_iter_max, 1.2*max(size(W))^3);


% use fast C-coded version if possible
if exist('perform_front_propagation_3d')~=0
    if nargin<4 
        [D,S] = perform_front_propagation_3d(W,start_points-1,end_points-1,nb_iter_max);
    else
        [D,S] = perform_front_propagation_3d(W,start_points-1,end_points-1,nb_iter_max, H);
    end
else
    error('The 3D fast marching is only implemented using a mex file, you must compile perform_front_propagation_3d.cpp.');
end

% replace C 'Inf' value (1e9) by Matlab Inf value.
I = find( D>10000 );
D(I) = Inf;
