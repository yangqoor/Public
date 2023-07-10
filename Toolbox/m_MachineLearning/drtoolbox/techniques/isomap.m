function [mappedX, mapping] = isomap(X, no_dims, k); 
%ISOMAP Runs the Isomap algorithm
%
%   [mappedX, mapping] = isomap(X, no_dims, k); 
%
% The functions runs the Isomap algorithm on dataset X to reduce the
% dimensionality of the dataset to no_dims. The number of neighbors used in
% the compuations is set by k (default = 12). This implementation does not
% use the Landmark-Isomap algorithm.
%
% If the neighborhood graph that is constructed is not completely
% connected, only the largest connected component is embedded. The indices
% of this component are returned in mapping.conn_comp.
%
%

% This file is part of the Matlab Toolbox for Dimensionality Reduction v0.2b.
% The toolbox can be obtained from http://www.cs.unimaas.nl/l.vandermaaten
% You are free to use, change, or redistribute this code in any way you
% want. However, it is appreciated if you maintain the name of the original
% author.
%
% (C) Laurens van der Maaten
% Maastricht University, 2007


    if ~exist('no_dims')
        no_dims = 2;
    end
    if ~exist('k')
        k = 12;
    end

    % Construct neighborhood graph
    disp('Constructing neighborhood graph...'); 
    D = find_nn(X, k);

    % Select largest connected component
    blocks = components(D)';
    count = zeros(1, max(blocks));
    for i=1:max(blocks)
        count(i) = length(find(blocks == i));
    end
    [count, block_no] = max(count);
    conn_comp = find(blocks == block_no);
    D = D(conn_comp,:);
    D = D(:,conn_comp);
    n = size(D, 1);

    % Compute shortest paths
    disp('Computing shortest paths...');
    D = dijkstra(D, [1:n]);
    
    % Performing MDS using eigenvector implementation
    disp('Constructing low-dimensional embedding...');
    M = -.5 * (D .^ 2 - sum(D .^ 2)' * ones(1, n) / n - ones(n, 1) * sum(D .^ 2) / n + sum(sum(D .^ 2)) / (n ^ 2));
	M(isnan(M)) = 0;
	M(isinf(M)) = 0;
    [vec, val] = eig(M);
	if size(vec, 2) < no_dims
		no_dims = size(vec, 2);
		warning(['Target dimensionality reduced to ' num2str(no_dims) '...']);
	end
	
    % Computing final embedding
    h = real(diag(val)); 
    [foo, sorth] = sort(h, 'descend');  
    val = real(diag(val(sorth, sorth))); 
    vec = vec(:,sorth);
    mappedX = real(vec(:,1:no_dims) .* (ones(n, 1) * sqrt(val(1:no_dims))')); 
    
    % Store data for out-of-sample extension
    mapping.conn_comp = conn_comp;
    mapping.k = k;
    mapping.X = X(conn_comp,:);
    mapping.D = D;
    mapping.vec = vec;
    mapping.val = val;