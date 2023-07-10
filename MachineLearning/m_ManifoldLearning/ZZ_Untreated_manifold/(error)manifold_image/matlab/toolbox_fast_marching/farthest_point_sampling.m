function [points,D] = farthest_point_sampling( W, points, nbr_iter, options )

% farthest_point_sampling - samples points using farthest seeding strategy
%
% points = farthest_point_sampling( W, points, nbr_points );
%
%   points can be [] or can be a (2,nb.points) matrix of already computed 
%       sampling locations.
%   
%   Copyright (c) 2005 Gabriel Peyre

options.null = 0;
if nargin<3
    nb_iter = 1;
end

n = size(W,1);

if isfield(options, 'constraint_map')
    L1 = options.constraint_map;
else
    L1 = zeros(n) + Inf;
end

if nargin<2 || isempty(points)
    % initialize farthest points at random
    points = round(rand(2,1)*(n-1))+1;
    % replace by farthest point
    [points,L] = farthest_point_sampling( W, points, 1 );
    points = points(:,end);
    nbr_iter = nbr_iter-1;
else
    % initial distance map
    L = min(zeros(n) + Inf, L1);
end

if nbr_iter>5
    hh = waitbar(0,['Performing farthest sampling.']);
end
for i=1:nbr_iter
    if nbr_iter>5
        waitbar( i/nbr_iter ,hh);
    end
    options.nb_iter_max = Inf;
    options.Tmax = sum(size(W));
    %     [D,S] = perform_fast_marching_2d(W, points, options);
    options.constraint_map = L;
    D = my_eval_distance(W, points(:,end), options);
    D = min(D,L); % known distance map to lanmarks
    L = min(D,L1); % cropp with other constraints
    % remove away data
    I = find(D==Inf); D(I) = 0;
    % compute farhtest points
    [tmp,I] = max(D(:));
    [a,b] = ind2sub(size(W),I(1));
    points = [points,[a;b]];
end
if nbr_iter>5
    close(hh);
end


function D = my_eval_distance(W,x, options)

options.null = 0;
n = size(W,1);

if std(W)==0
    if size(x,2)>1
        D = zeros(n)+Inf;
        for i=1:size(x,2)
            D = min(D, my_eval_distance(W,x(:,i)));
        end
        return;
    end
    [Y,X] = meshgrid(1:n,1:n);
    D = 1/W(1) * sqrt( (X-x(1)).^2 + (Y-x(2)).^2 );
else
    [D,Z] = perform_fast_marching_2d(W, x, options);
end