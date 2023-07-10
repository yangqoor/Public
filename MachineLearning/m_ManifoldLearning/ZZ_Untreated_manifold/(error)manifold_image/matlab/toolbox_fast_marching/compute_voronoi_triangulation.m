function faces = compute_voronoi_triangulation(Q, vertex)

% compute_voronoi_triangulation - compute a triangulation
%
%   face = compute_voronoi_triangulation(Q);
%
%   Q is a Voronoi partition function, computed using perform_fast_marching_2d.
%
%   face = compute_voronoi_triangulation(Q);
%
%   Copyright (c) 2006 Gabriel Peyr?


V = [];
v = Q(1:end-1,1:end-1); V = [V v(:)];
v = Q(2:end,1:end-1); V = [V v(:)];
v = Q(1:end-1,2:end); V = [V v(:)];
v = Q(2:end,2:end); V = [V v(:)];

V = sort(V,2);
V = unique(V, 'rows');
V = V( prod(V,2)>0 ,:);


d = (V(:,1)~=V(:,2)) + (V(:,2)~=V(:,3)) + (V(:,3)~=V(:,4));
if sum(d==3)>1
    warning('Problem with triangulation.');
end

% split squares into 2 triangles
I = find(d==3);
faces = [];
for i=1:length(I)
    v = V(I(i),:);
    x = vertex(:,v); % points
    % barycenter
    a = sum( x, 2 ) / 4;
    x = x-repmat(a, [1 size(x,2)]);
    t = atan2(x(2,:),x(1,:));
    [tmp,s] = sort(t);
    faces = [faces; v( s([1 2 3]))];
    faces = [faces; v( s([3 4 1]))];
    
end
%    faces = [V(I,1:3);V(I,[3 4 1])];

% remaining triangles
V = V( d==2 ,:);
for i=1:size(V,1)
    V(i,1:3) = unique(V(i,:));
end
faces = [faces; V(:,1:3)];
