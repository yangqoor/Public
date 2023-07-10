function path = extract_path_3d(A,end_points,options)

% extract_path_3d - extract the shortest path using 
%   a gradient descent.
%
%   path = extract_path_3d(A,x,options);
%
%   'A' is the distance function.
%   'x' is starting point (should be integer). 
%
%   Copyright (c) 2004 Gabriel Peyré


options.null = 0;

if isfield(options, 'trim_path')
    trim_path = options.trim_path;
else
    trim_path = 1;
end

% gradient computation
I = find(A==Inf);
J = find(A~=Inf);
A1 = A; A1(I) = mmax(A(J));
global gx;
global gy;
global gz;
[gy,gx,gz] = gradient(A1);

% normalize the gradient field
d = sqrt( gx.^2 + gy.^2 + gz.^2 );
I = find(d<eps);
d(I) = 1;
gx = gx./d; gy = gy./d; gz = gz./d;

% path extraction
options = [0.2 20000];
path = stream3(-gy,-gx,-gz,end_points(2,:),end_points(1,:),end_points(3,:), options);
for i=1:length(path)
     path{i} = path{i}(:,[2:-1:1 3]);
end
if length(path)==1
    path = path{1};
end

% test if path is long enough
v = path(end,:);
v1 = max(round(v),ones(1,3));
if( 0 && A1(v1(1),v1(2),v1(3))>0.1 )
    path1 = stream3(-gy,-gx,-gz,v(2),v(1),v(3), options);
    for i=1:length(path1)
        path1{i} = path1{i}(:,[2:-1:1 3]);
    end
    if length(path)>=1
        path1 = path1{1};
    end
    path = [path; path1];
end

if isfield(options, 'start_points')
    start_points = options.start_points;
else
    start_points = path(end,:);
end
start_points = start_points(:);

if trim_path
    % removing too verbose points
    d = compute_distance_to_points(path', start_points);
    % perform thresholding
    T = mmax(d)/300^2;
    I = find(d<T);
    if ~isempty(I)
        path = path(1:I(1), :);
        path = [path; start_points'];
    end
end



return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        OLD CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isfield(options, 'Tmax')
    Tmax = options.Tmax;
else
    Tmax = sum(size(A));
end

x = x(:);

% path is empty
path = x;

[T,path] = ode113( @get_gradient, [0,Tmax], x);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% subfunction
function g = get_gradient( t, y )

global gx;
global gy;
global gz;

[nx,ny,nz] = size(gx);

% down/left corner of current cell
p = floor(y(1));
q = floor(y(2));
r = floor(y(3));
    
p = clamp(p,1,nx-1);
q = clamp(q,1,ny-1);
r = clamp(r,1,nz-1);

% residual in [0,1]
xx = y(1)-p;
yy = y(2)-q;
zz = y(3)-r;

xx = clamp(xx,0,1);
yy = clamp(yy,0,1);
zz = clamp(zz,0,1);

% compute gradient    
a = [gx(p,q,r), gy(p,q,r), gz(p,q,r)];
b = [gx(p+1,q,r), gy(p+1,q,r), gz(p+1,q,r)];
c = [gx(p,q+1,r), gy(p,q+1,r), gz(p,q+1,r)];
d = [gx(p+1,q+1,r), gy(p+1,q+1,r), gz(p+1,q+1,r)];     
g1 = ( a*(1-xx)+b*xx )*(1-yy) + ( c*(1-xx)+d*xx )*yy;

a = [gx(p,q,r+1), gy(p,q,r+1), gz(p,q,r+1)];
b = [gx(p+1,q,r+1), gy(p+1,q,r+1), gz(p+1,q,r+1)];
c = [gx(p,q+1,r+1), gy(p,q+1,r+1), gz(p,q+1,r+1)];
d = [gx(p+1,q+1,r+1), gy(p+1,q+1,r+1), gz(p+1,q+1,r+1)];     
g2 = ( a*(1-xx)+b*xx )*(1-yy) + ( c*(1-xx)+d*xx )*yy;

g = g1*(1-zz) + g2*zz;
g = -g';