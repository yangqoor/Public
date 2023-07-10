function path = extract_path_2d(A,end_points,options)

% extract_path_2d - extract the shortest path using 
%   a gradient descent.
%
%   path = extract_path_2d(A,end_points,options);
%
%   'A' is the distance function.
%   'end_points' is starting point (should be integer). 
%
%   Copyright (c) 2004 Gabriel Peyré

options.null = 0;

if isfield(options, 'trim_path')
    trim_path = options.trim_path;
else
    trim_path = 1;
end

if isfield(options, 'stepsize')
    stepsize = options.stepsize;
else
    stepsize = 0.1;
end
if isfield(options, 'maxverts')
    maxverts = options.maxverts;
else
    maxverts = 10000;
end
str_options = [stepsize maxverts];

if size(end_points,1)~=2
    end_points = end_points';
end
if size(end_points,1)~=2
    error('end_points should be of size 2xk');
end

% gradient computation
I = find(A==Inf);
J = find(A~=Inf);
A1 = A; A1(I) = mmax(A(J));
global grad;
grad = compute_grad(A1);
grad = -perform_vf_normalization(grad);

% path extraction
path = stream2(grad(:,:,2),grad(:,:,1),end_points(2,:),end_points(1,:), str_options);
for i=1:length(path)
    path{i} = path{i}(:,2:-1:1);
end
if length(path)==1
    path = path{1};
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
    path = path(1:I(1), :);
    path = [path; start_points'];
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        OLD METHOD USING ODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if isfield(options, 'Tmax')
    Tmax = options.Tmax;
else
    Tmax = sum(size(A));
end

global start_points;
if isfield(options, 'start_points')
    start_points = options.start_points;
else
    start_points = [];
end

x = x(:);

% path is empty
path = x;


% n * mmax(A(J));
% x = xv;

options = odeset('Events',@event_callback);
[T,path] = ode113( @get_gradient, [0,Tmax], x, options);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% subfunction
function [value,isterminal,direction] = event_callback(t,y)

global start_points;
% compute distance to start points
d = compute_distance_to_points(y,start_points);
value = min(d);
if value<0.1
    value = -1;
end
isterminal = 1;
direction = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% subfunction
function g = get_gradient( t, y )

global grad;
gx = grad(:,:,1);
gy = grad(:,:,2);

n = length(gx);

% down/left corner of current cell
p = floor(y(1));
q = floor(y(2));
    
p = clamp(p,1,n-1);
q = clamp(q,1,n-1);

% residual in [0,1]
xx = y(1)-p;
yy = y(2)-q;

xx = clamp(xx,0,1);
yy = clamp(yy,0,1);

% compute gradient    
a = [gx(p,q), gy(p,q)];
b = [gx(p+1,q), gy(p+1,q)];
c = [gx(p,q+1), gy(p,q+1)];
d = [gx(p+1,q+1), gy(p+1,q+1)];     
g = ( a*(1-xx)+b*xx )*(1-yy) + ( c*(1-xx)+d*xx )*yy;
g = -g';