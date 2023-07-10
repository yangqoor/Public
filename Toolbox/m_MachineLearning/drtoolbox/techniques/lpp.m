function [mappedX, mapping] = lpp(X, no_dims, k, eig_impl)
%LPP Perform linearity preserving projection
%
%   [mappedX, mapping] = lpp(X, no_dims, k)
%   [mappedX, mapping] = lpp(X, no_dims, k, eig_impl)
%
% Perform the Linearity Preserving Projection on dataset X to reduce it to 
% dimensionality no_dims. The number of neighbors that is used by LPP is
% specified by k (default = 12).
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

    if size(X, 2) > size(X, 1)
        error('Number of samples should be higher than number of dimensions.');
    end
    if ~exist('no_dims', 'var')
        no_dims = 2; 
    end
    if ~exist('k', 'var')
        k = 12;
    end
    if ~exist('eig_impl', 'var')
        eig_impl = 'Matlab';
    end
    
    % Copy old data
    tmp_mean = mean(X, 1);
	X = X - repmat(tmp_mean, [size(X, 1) 1]);
    old_X = X;
    
    % Compute affinity matrix W
    W = find_nn(X, k);

    % Perform PCA on the data
    [X, mapping] = pca(X, size(X, 2));
    mapping.mean = tmp_mean;
    
    % Compute degree and Laplacian of affinity matrix
    D = diag(sum(W));
    L = D - W;

    % Compute XDX and XLX and make sure these are symmetric
    DP = X' * D * X;
    LP = X' * L * X;
    DP = (DP + DP') / 2;
    LP = (LP + LP') / 2;

    % Perform eigenanalysis of generalized eigenproblem (as in LEM)
    if size(X, 1) > 200 && no_dims < (size(X, 1) / 2)
        if strcmp(eig_impl, 'JDQR')
            options.Disp = 0;
            options.LSolver = 'bicgstab';
            [eigvector, eigvalue] = jdqz(LP, DP, no_dims, 'LR', options);
        else
            options.disp = 0;
            options.issym = 1;
            options.isreal = 1;
            [eigvector, eigvalue] = eigs(LP, DP, no_dims, 'LA', options);
        end
    else
        [eigvector, eigvalue] = eig(LP, DP);
    end
    
    % Sort eigenvalues in descending order and get largest eigenvectors
    [eigvalue, ind] = sort(diag(eigvalue), 'descend');
    eigvector = eigvector(:,ind(1:no_dims));

    % Normalize eigenvectors
    for i=1:size(eigvector, 2)
        eigvector(:,i) = eigvector(:,i) ./ norm(eigvector(:,i));
    end
    
    % Compute final linear basis and map data
    eigvector = mapping.M * eigvector;
    mappedX = old_X * eigvector;
    mapping.M = eigvector;
