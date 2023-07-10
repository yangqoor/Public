function [X,col] = load_points_set( name, n, options )

% load_points_set - load a 3D sample dataset
%
%   [X,col] = load_points_set( name, n, options );
%
%   name is either
%   'swissroll','square','scurve','swisshole','corner_plane',
%   'puncted_sphere','twin_peaks','3d_cluster','toroidal_helix','rand_gaussian'
%   'spiral', 'circles'
%   n is the number of points
%   options.sampling can be 'rand' or 'uniform'
%   options.noise_level is to add some jitter.
%
%   Copyright (c) 2005 Gabriel Peyr?

options.null = 0;

if isfield(options, 'noise_level')
    noise_level = options.noise_level;
else
    noise_level = 0;
end

if isfield(options, 'sampling')
    sampling = options.sampling;
else
    sampling = 'rand';
end

if strcmp( name, 'scurve' )
    n = round(n/2);
end

if strcmp(sampling, 'rand')
    x = rand(n,1); y = rand(n,1);
elseif strcmp(sampling, 'randnonunif')
    % makes sampling denser in the border
    x = 2*rand(n,1)-1; y = 2*rand(n,1)-1;
    x = sign(x) .* abs(x).^0.5;
    y = sign(y) .* abs(y).^0.5;
    x = (x+1)/2; y = (y+1)/2;
else
    n = ceil(sqrt(n))^2;
    x = linspace(0,1,sqrt(n));
    [y,x] = meshgrid(x,x);
    x = x(:); y = y(:);
end

col = x;
X = zeros(3,n);
X(1,:) = x;
X(2,:) = y;

ExParam = 1;

switch lower(name)
    case 'swissroll'
        s = 1.5; % # tours
        L = 21; % width
        v = 3*pi/2 * (1 + 2*x');
        X(2,:) = L * y';
        X(1,:) = cos( v ) .* v;
        X(3,:) = sin( v ) .* v;
        
    case 'swisshole'
        s = 1.5; % # tours
        L = 21; % width
        v = 3*pi/2 * (1 + 2*x');
        X(2,:) = L * y';
        X(1,:) = cos( v ) .* v;
        X(3,:) = sin( v ) .* v;
        
        d = (x-0.5).^2 + (y-0.5).^2;
        I = find(d<0.15^2);
        X(:,I) = [];
        col(I) = [];       
       
    case  'scurve'
        X = zeros(3,2*n);
        tt = (1.5*x-1)*pi; uu = tt(end:-1:1); hh = [y;y]*5;
        X(1,:) = [cos(tt); -cos(uu)]';
        X(2,:) = hh';
        X(3,:) = [sin(tt); 2-sin(uu)]';
        col = [tt;uu]';
          
end

% X = reshape(X,3,max(size(X)));

X = X + randn(size(X))*noise_level;