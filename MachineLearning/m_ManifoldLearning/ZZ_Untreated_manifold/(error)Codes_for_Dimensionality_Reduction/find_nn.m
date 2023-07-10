function [D, ni] = find_nn(X, k, type)
%FIND_NN Finds k nearest neigbors for all datapoints in the dataset
%
%	[D, ni] = find_nn(X, k, type)
%
% Finds the k nearest neighbors for all datapoints in the dataset X.
% In X, rows correspond to the observations and columns to the
% dimensions. The value of k is the number of neighbors that is
% stored. The function returns a sparse distance matrix D, in which
% only the distances to the k nearest neighbors are stored. For
% equal datapoints, the distance is set to a tolerance value.
% The method is relatively slow, but has a memory requirement of O(nk).
% Type can be 'eucl' (default) or 'sqeucl'.
%
%

% This file is part of the Matlab Toolbox for Dimensionality Reduction v0.3b.
% The toolbox can be obtained from http://www.cs.unimaas.nl/l.vandermaaten
% You are free to use, change, or redistribute this code in any way you
% want for non-commercial purposes. However, it is appreciated if you 
% maintain the name of the original author.
%
% (C) Laurens van der Maaten
% Maastricht University, 2007

	if ~exist('k', 'var')
		k = 12;
    end
    if ~exist('type', 'var')
		type = 'eucl';
    end
    
    % Perform adaptive neighborhood selection if desired
    if ischar(k)
        [D, max_k] = find_nn_adaptive(X);
        ni = zeros(size(X, 1), max_k);
        for i=1:size(X, 1)
            tmp = find(D(i,:) ~= 0);
            tmp = sort(tmp, 'ascend');
            tmp = [tmp(2:end) zeros(1, max_k - length(tmp) + 1)];
            ni(i,:) = tmp;
        end
    
    % Perform normal neighborhood selection
    else

        % Memory conservative implementation
        if size(X, 1) > 2000
            X = X';
            n = size(X, 2);
            D = sparse(n, n);
            XX = sum(X .^ 2);
            onez = ones(1,n);
            if nargout > 1, ni = zeros(n, k, 'uint16'); end
            for i=1:n
                p = X(:,i);
                xx = sum(p .^ 2);
                xX = p' * X;
                if strcmp(type, 'eucl')
                    d = xx * onez + XX - 2 * xX;
                    [d, ind] = sort(d);
                    d = sqrt(d(1:k));
                else
                    d = abs(xx * onez + XX - 2 * xX);
                    [d, ind] = sort(d);
                    d = d(1:k);
                end
                ind = ind(1:k);
                d(d == 0) = 1e-7;
                D(i, ind) = d;
                if nargout > 1, ni(i,:) = ind; end
            end

        % Faster implementation
        else
            n = size(X, 1);
            if strcmp(type, 'eucl')
                D = squareform(pdist(X, 'euclidean'));
            else
                D = squareform(pdist(X, 'seuclidean'));
            end
            [foo, ind] = sort(D, 2);

            flat = repmat((1:n)', 1, n-k) + n*ind(:, k+1:end) - n;
            D(flat(:)) = 0;
            D(1:n+1:end) = 1e-7;
            D = sparse(double(D));

            if nargout > 1, ni = uint16(ind(:,1:k)); end
        end
    end