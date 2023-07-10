function [D,S,Q] = perform_fast_marching_2d(W, start_points, options, H)

% perform_fast_marching_2d - launch the Fast Marching algorithm.
%
%   [D,S,Q] = perform_fast_marching_2d(W, start_points, options)
%
%   'W' is the weight matrix (the highest, the slowest the front will move).
%   'start_points' is a 2 x k array, start_points(:,i) is the ith starting point .
%
%   D is the distance function to the set of starting points.
%   S is the final state of the points : -1 for dead (ie the distance
%       has been computed), 0 for open (ie the distance is only a temporary
%       value), 1 for far (ie point not already computed). Distance function
%       for far points is Inf.
%   Q is the index of the closest point. Q is set to 0 for far points.
%       Q provide a Voronoi decomposition of the domain. 
%
%   Optional:
%   - You can provide special conditions for stop in options :
%       'options.end_points' : stop when these points are reached
%       'options.nb_iter_max' : stop when a given number of iterations is
%          reached.
%   - You can provide an heuristic in options.heuristic (typically that try to guess the distance
%       that remains from a given node to a given target).
%       This is an array of same size as W.
%   - You can provide a map L=options.constraint_map that reduce the set of
%       explored points. Only points with current distance smaller than L
%       will be expanded. Set some entries of L to -Inf to avoid any
%       exploration of these points.
%   - options.values set the initial distance value for starting points
%   (default value is 0).
%
%   Copyright (c) 2004-2006 Gabriel Peyr?


if nargin<3
    options.null = 0;
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
    nb_iter_max = Inf;
end
if isfield(options,'values')
    values = options.values;
else
    values = [];
end

if isfield(options,'constraint_map')
    L = options.constraint_map;
else
    L = [];
end
I = find(L==-Inf); L(I)=-1e9;
I = find(L==Inf); L(I)=1e9;

if isfield(options,'heuristic')
    H = options.heuristic;
else
    if nargin<4
        H = [];
    end
end

nb_iter_max = min(nb_iter_max, 1.2*max(size(W))^2);


% use fast C-coded version if possible
if exist('perform_front_propagation_2d')~=0
    [D,S,Q] = perform_front_propagation_2d(W,start_points-1,end_points-1,nb_iter_max, H, L, values);
    Q = Q+1;
else
    if nargin<4
        [D,S] = perform_front_propagation_2d_slow(W,start_points,end_points,nb_iter_max);
    else
        [D,S] = perform_front_propagation_2d_slow(W,start_points,end_points,nb_iter_max, H);
    end
end

% replace C 'Inf' value (1e9) by Matlab Inf value.
I = find( D>1e8 );
D(I) = Inf;
