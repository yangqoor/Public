function plot_fast_marching_2d(W,S,path,start_points,end_points, options)

% plot_fast_marching_2d - plot the result of the fast marching.
%
%   plot_fast_marching_2d(W,S,path,start_points,end_points, options);
%
%   Copyright (c) 2004 Gabriel Peyré


n = size(W,1);

options.null = 0;
if isfield(options, 'path_width')
    path_width = options.path_width;
else
    path_width = 3;
end
if isfield(options, 'point_size')
    point_size = options.point_size;
else
    point_size = 12;
end

if isfield(options, 'start_point_style')
    start_point_style = options.start_point_style;
else
    start_point_style = 'kx';
end
if isfield(options, 'end_point_style')
    end_point_style = options.end_point_style;
else
    end_point_style = 'k*';
end

if ~iscell(end_point_style)
    end_point_style = {end_point_style, 'b.'};
end
if ~iscell(point_size)
    point_size = {point_size, 20};
end


Z = repmat(W',[1,1,3]);
S1 = repmat(S',[1,1,3]);
S1(:,:,1) = Inf;
open_list = find( S1==0 );
close_list = find( S1==-1 );

set(gca,'box','on');

hold on;
% Z(open_list) = 0;
Z(close_list) = 0;
imagesc( rescale(Z) );
axis image;
axis off;

c_list = perform_curve_extraction(S,0);
for k=1:length(c_list);
    c_list{k} = c_list{k}*(n-1)+1;
end
for i=1:length(c_list)
    plot(c_list{i}(1,:), c_list{i}(2,:), 'r-', 'LineWidth', 2);
end

% axis square;
if nargin>=4 & ~isempty(start_points)
    if size(start_points,1)~=2
        start_points = start_points';
    end
    if size(start_points,1)~=2
        error('start_points must be of size 2xk');
    end
    for i=1:size(start_points,2)
	    plot(start_points(1,i), start_points(2,i), start_point_style, 'MarkerSize', point_size{1});
    end
end
if nargin>=5 & ~isempty(end_points)
    if size(end_points,1)~=2
        end_points = end_points';
    end
    if size(end_points,1)~=2
        error('end_points must be of size 2xk');
    end
    for i=1:size(end_points,2)
        plot(end_points(1,i), end_points(2,i), end_point_style{1 + (i>1)}, 'MarkerSize', point_size{1 + (i>1)});
    end
end
if nargin>=3
    if ~iscell(path)
        path = {path};
    end
    for i=1:length(path)
        plot(path{i}(:,1), path{i}(:,2), '-', 'LineWidth', path_width);
    end
end
hold off;