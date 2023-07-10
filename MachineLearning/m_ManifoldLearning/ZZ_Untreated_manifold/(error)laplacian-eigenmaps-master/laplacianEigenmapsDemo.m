%% LAPLACIANEIGENMAPSDEMO.M
% Several examples demonstrating the use of laplacianEigenmaps.m
% (c) 2017 Jacob Zavatone-Veth (MIT License)

%% Set generic parameters

% Number of points
N = 10000;

% Noise term weighting (for Swiss roll and S-curve)
noise = 0.05;

% Size of points (for plotting)
sz = 10;

% Set options for embedding
opts = {'Distance', 'Euclidean',...
    'Sigma', 1,...
    'NumNeighbors', 10,...
    'NumDimensions', 2,...
    'Verbose', 1};

%% Line in 3d space

% Create the data
x = linspace(0, 100, N)';
X = [x,x,x];

% Compute the embedding
Y = laplacianEigenmaps( X, opts{:} );

% Plot 3D input and 2D result
figure('Position',[200,500,1000,1000],'WindowStyle','docked');
subplot(1,2,1);
scatter3(X(:,1),X(:,2),X(:,3),sz,x,'fill');
axis('equal','tight');
title('Line');
subplot(1,2,2);
scatter(Y(:,1),Y(:,2),sz,x,'fill');
axis('equal','tight');
title('Embedding');

%% 2D grid embedded in 3D space

% Create the data
x = linspace(0, 100, sqrt(N));
y = linspace(0, 100, sqrt(N));
[xx, yy] = meshgrid(x,y);
xx = xx(:); yy = yy(:);
X = [xx,yy,xx];

% Compute the embedding
Y = laplacianEigenmaps( X, opts{:} );

% Plot 3D input and 2D result
figure('Position',[200,500,1000,1000],'WindowStyle','docked');
subplot(1,2,1);
scatter3(X(:,1),X(:,2),X(:,3),sz,xx,'fill');
axis('equal','tight');
title('2D grid');
subplot(1,2,2);
scatter(Y(:,1),Y(:,2),sz,xx,'fill');
axis('equal','tight');
title('Embedding');

%% Swiss roll

% Create the data
t = 3*pi/2 * (1 + 2*rand(N,1));
h = 11 * rand(N,1);
X = [t.*cos(t), h, t.*sin(t)] + noise*randn(N,3);

% Compute the embedding
Y = laplacianEigenmaps( X, opts{:} );

% Plot 3D input and 2D result
figure('Position',[200,500,1000,1000],'WindowStyle','docked');
subplot(1,2,1);
scatter3(X(:,1),X(:,2),X(:,3),sz,t,'fill');
axis('equal','tight');
title('Swiss roll');
subplot(1,2,2);
scatter(Y(:,1),Y(:,2),sz,t,'fill');
axis('equal','tight');
title('Embedding');

%% S-curve

% Create the data
t = 3 * pi * (rand(N,1) - 0.5);
x = sin(t);
y = 2.0 * rand(N,1);
z = sign(t) .* (cos(t) - 1);
X = [x,y,z] + noise*randn(N,3);

% Compute the embedding
Y = laplacianEigenmaps( X, opts{:} );

% Plot 3D input and 2D result
figure('Position',[200,500,1000,1000],'WindowStyle','docked');
subplot(1,2,1);
scatter3(X(:,1),X(:,2),X(:,3),sz,t,'fill');
axis('equal','tight');
title('S-curve');
subplot(1,2,2);
scatter(Y(:,1),Y(:,2),sz,t,'fill');
axis('equal','tight');
title('Embedding');

%% Severed sphere

p = rand(N,1) * (2 * pi - 0.55);
t = rand(N,1) * pi;

% Sever the poles from the sphere.
indices = ((t < (pi - (pi / 8))) & (t > ((pi / 8))));
c = p(indices);
X = [sin(t(indices)) .* cos(p(indices)),  sin(t(indices)) .* sin(p(indices)),  cos(t(indices))];

Y = laplacianEigenmaps( X, opts{:} );

% Plot 3D input and 2D result
figure('Position',[200,500,1000,1000],'WindowStyle','docked');
subplot(1,2,1);
scatter3(X(:,1),X(:,2),X(:,3),sz,c,'fill');
axis('equal','tight');
title('Severed sphere');
subplot(1,2,2);
scatter(Y(:,1),Y(:,2),sz,c,'fill');
axis('equal','tight');
title('Embedding');

