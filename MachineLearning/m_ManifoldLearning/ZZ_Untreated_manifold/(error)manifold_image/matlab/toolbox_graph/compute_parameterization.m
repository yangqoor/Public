function vertex1 = compute_parameterization(vertex,face, options)

% compute_parameterization - compute a planar parameterization
%
%   vertex1 = compute_parameterization(vertex,face, options);
%
%   options.method can be:
%       'parameterization': solve classical parameterization, the boundary
%           is specified by options.boundary which is either 'circle',
%           'square' or 'triangle'. The kind of laplacian used is specified
%           by options.laplacian which is either 'combinatorial' or 'conformal'
%       'freeboundary': same be leave the boundary free.
%       'flattening': solve spectral embedding using a laplacian
%           specified by options.laplacian.
%       'isomap': use Isomap approach.
%       'drawing': to draw a graph whose adjacency is options.A.
%           Then leave vertex and face empty.
%
%   Copyright (c) 2007 Gabriel Peyr?


options.null = 0;
if isfield(options, 'method')
    method = options.method;
else
    method = 'parameterization';
end
if isfield(options, 'laplacian')
    laplacian = options.laplacian;
else
    laplacian = 'conformal';
end
if isfield(options, 'boundary')
    boundary = options.boundary;
else
    boundary = 'square';
end
if isfield(options, 'ndim')
    ndim = options.ndim;
else
    ndim = 2;
end

if size(vertex,2)<size(vertex,1)
    vertex = vertex';
end
if size(face,2)<size(face,1)
    face = face';
end
options.symmetrize=1;
options.normalize=0;

switch lower(method)
    
    case 'parameterization'
        vertex1 = compute_parametrization_boundary(vertex,face,laplacian,boundary);
        
    case 'freeboundary'
        vertex1 = compute_parameterization_free(vertex,face, laplacian);
        
    case 'drawing'
        if isfield(options, 'A')
            A = options.A;
        else
            error('You must specify options.A.');
        end
        L = compute_mesh_laplacian(vertex,face,'combinatorial',options);
        [U,S,V] = eigs(L, ndim+1, 'SM');
        if abs(S(1))<eps
            vertex1 = U(:,end-ndim+1:end);
        elseif abs(S(ndim))<eps
            vertex1 = U(:,1:ndim);
        else
            error('Problem with Laplacian matrix');
        end
            
        
    case 'flattening' 
    	L = compute_mesh_laplacian(vertex,face,laplacian,options);
        [U,S,V] = eigs(L, ndim+1, 'SM');
        if abs(S(1))<eps
            vertex1 = U(:,end-ndim+1:end);
        elseif abs(S(ndim))<eps
            vertex1 = U(:,1:ndim);
        else
            error('Problem with Laplacian matrix');
        end
        
        
    case 'isomap'
        A = triangulation2adjacency(face);
        % build distance graph
        D = build_euclidean_weight_matrix(A,vertex,Inf);
        vertex1 = isomap(D,ndim);
        if ndim==2
            vertex1 = rectify_embedding(vertex(:,1:ndim),vertex1);
        end
        
        
    otherwise
        error('Unknown method.');
end



function xy_spec1 = rectify_embedding(xy,xy_spec)

% rectify_embedding - try to match the embeding
%   with another one.
%   Use the Y coord to select 2 base points.
%
%   xy_spec = rectify_embedding(xy,xy_spec);
%
%   Copyright (c) 2003 Gabriel Peyr?

I = find( xy(:,2)==max(xy(:,2)) );
n1 = I(1); 
I = find( xy(:,2)==min(xy(:,2)) );
n2 = I(1);
v1 = xy(n1,:)-xy(n2,:);
v2 = xy_spec(n1,:)-xy_spec(n2,:);
theta = acos( dot(v1,v2)/sqrt(dot(v1,v1)*dot(v2,v2)) );
theta = theta * sign( det([v1;v2]) );
M = [cos(theta) sin(theta); -sin(theta) cos(theta)];
xy_spec1 = (M*xy_spec')';



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xy = compute_parameterization_free(vertex,face, laplacian)


n = size(vertex,2);

% extract boundary
boundary = compute_boundary(face);
nbound = length(boundary);

options.symmetrize=1;
options.normalize=0;

% compute Laplacian  
if ~isstr(laplacian)
    L = laplacian;
    laplacian = 'user';
else	
    	L = compute_mesh_laplacian(vertex,face,laplacian,options);
end

A = sparse(2*n,2*n);
A(1:end/2,1:end/2) = L;
A(end/2+1:end,end/2+1:end) = L;

% set up boundary conditions
for s = 1:nbound
    % neighboring values
    s1 = mod(s-2,nbound)+1;
    s2 = mod(s,nbound)+1;
    i = boundary(s);
    i1 = boundary(s1);
    i2 = boundary(s2);
    e = 1;
    A(i,i1+n) = +e;
    A(i,i2+n) = -e;
    A(i+n,i1) = -e;
    A(i+n,i2) = +e;
end
% set up pinned vertices
i1 = boundary(1);
i2 = boundary(round(end/2));
A(i1,:) = 0;  A(i1+n,:) = 0;
A(i1,i1) = 1; A(i1+n,i1+n) = 1;
A(i2,:) = 0;  A(i2+n,:) = 0;
A(i2,i2) = 1; A(i2+n,i2+n) = 1;
p1 = [0 0]; p2 = [1 0]; % position of pinned vertices
y = zeros(2*n,1);
y(i1) = p1(1); y(i1+n) = p1(2);
y(i2) = p2(1); y(i2+n) = p2(2);

% solve for the position
xy = A\y;
xy = reshape(xy, [n 2])';


function xy = compute_parametrization_boundary(vertex,face,laplacian,boundary_type)

% compute_parametrization - compute a planar parameterization
%   of a given disk-like triangulated manifold.
%
%   compute_parametrization(vertex,face,laplacian,boundary_type);
%
%   'laplacian' is either 'combinatorial', 'conformal' or 'authalic'
%   'boundary_type' is either 'circle', 'square' or 'triangle'
%
%   Copyright (c) 2004 Gabriel Peyr?

if size(vertex,2)>size(vertex,1)
    vertex = vertex';
end
if size(face,2)>size(face,1)
    face = face';
end

nface = size(face,1);
nvert = max(max(face));


options.symmetrize=1;
options.normalize=0;

if nargin<2
    error('Not enough arguments.');
end
if nargin<3
    laplacian = 'conformal';
end
if nargin<4
    boundary_type = 'circle';
end

if ~isstr(laplacian)
    L = laplacian;
    laplacian = 'user';
else
    % compute Laplacian
	L = compute_mesh_laplacian(vertex,face,laplacian,options);
end

% compute the boundary
boundary = compute_boundary(face);

% compute the position of the boundary vertex
nbound = length(boundary);
xy_boundary = zeros(nbound,2);
% compute total length
d = 0;
ii = boundary(end); % last index
for i=boundary
    d = d + norme( vertex(i,:)-vertex(ii,:) );
    ii = i;
end
% compute boundary vertex position
l = 0;
ii = boundary(end); % last index
for k=1:nbound
    i = boundary(k);
    ii = boundary( mod(k,nbound)+1 );   % next point
    t = l/d;
    
    switch lower(boundary_type)
        case 'circle'
            xy_boundary(k,:) = [cos(2*pi*t),sin(2*pi*t)];
        case 'square'
            if t<0.25
                xy_boundary(k,:) = [4*t,0];
            elseif t<0.5
                xy_boundary(k,:) = [1,4*t-1];
            elseif t<0.75
                xy_boundary(k,:) = [3-4*t,1];
            else
                xy_boundary(k,:) = [0,4-4*t];
            end
        case 'triangle'
            if t<1/3
                xy_boundary(k,:) = [3*t,0];
            elseif t<2/3
                xy_boundary(k,:) = (3*t-1)*[0.5,sqrt(2)/2] + (2-3*t)*[1,0];
            else
                xy_boundary(k,:) = (3-3*t)*[0.5,sqrt(2)/2];
            end
        otherwise
            error('Unknown boundary type.');
    end
    
    l = l + norme( vertex(i,:)-vertex(ii,:) );
end

% set up the matrix
M = L;
for i=boundary
    M(i,:) = zeros(1,nvert);
    M(i,i) = 1;
end
% solve the system
xy = zeros(nvert,2);
for coord = 1:2
    % compute right hand side
    x = zeros(nvert,1);
    x(boundary) = xy_boundary(:,coord);
    xy(:,coord) = M\x;
end


function y = norme( x );
y = sqrt( sum(x(:).^2) );