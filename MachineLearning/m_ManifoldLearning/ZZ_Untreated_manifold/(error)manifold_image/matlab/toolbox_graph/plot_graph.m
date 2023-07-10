function plot_graph(A,xy, options)

% plot_graph - display a 2D or 3D graph.
%
% plot_graph(A,xy, col);
%
%   Copyright (c) 2006 Gabriel Peyr?

if size(xy,1)>size(xy,2)
    xy = xy';
end

if nargin<3
    options.null = 0;
end
if not(isstruct(options))
    col = options; clear options;
    options.null = 0;
else
    if isfield(options, 'col')
        col = options.col;
    else
            col = 'k.-';
    end
end

B = full(A); B = B(:); B = B( B~=0 );
isvarying = std(B)>0;

if size(xy,1)==2
    if ~isstr(col)
        col = [];
    end
    % 2D display
    if ~isvarying
        gplot(A,xy', col);
    else
        gplotvarying(A,xy, col);
    end
    axis tight; axis equal; axis off;
elseif size(xy,1)==3
    % 3D display
    if isstr(col)
        if ~isvarying
            gplot3(A,xy', col);
        else
            gplotvarying3(A,xy, col);
        end
    else
        hold on;
        if ~isvarying
            gplot3(A,xy', col);
        else
            gplotvarying3(A,xy, col);
        end
        plot_scattered(xy, col);
        hold off;
        view(3);
    end
    axis off;
    cameramenu;
else
    error('Works only for 2D and 3D graphs');
end


function gplotvarying3(A,xy,col)


[i,j,s] = find(sparse(A));
I = find(i<=j); 
i = i(I); j = j(I); s = s(I);
s = s/max(s)*5;
hold on;
for k=1:length(i)
    A = [xy(:,i(k)) xy(:,j(k))];
    h = plot3( A(1,:), A(2,:), A(3,:),  col );
    set(h, 'LineWidth', s(k));
end
hold off;

function gplot3(A,xy,lc)


[i,j] = find(A);
[ignore, p] = sort(max(i,j));
i = i(p);
j = j(p);

% Create a long, NaN-separated list of line segments,
% rather than individual segments.

X = [ xy(i,1) xy(j,1) repmat(NaN,size(i))]';
Y = [ xy(i,2) xy(j,2) repmat(NaN,size(i))]';
Z = [ xy(i,3) xy(j,3) repmat(NaN,size(i))]';
X = X(:);
Y = Y(:);
Z = Z(:);

if nargin<3,
    plot3(X, Y, Z)
else
    plot3(X, Y, Z, lc);
end