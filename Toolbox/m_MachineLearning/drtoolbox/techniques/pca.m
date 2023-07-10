function [mappedX, mapping] = pca(X, no_dims)
%PCA Perform the PCA algorithm
%
%   [mappedX, mapping] = pca(X, no_dims)
%
% The function runs PCA on a set of datapoints X. The variable
% no_dims sets the number of dimensions of the feature points in the 
% embedded feature space (no_dims >= 1, default = 2). 
% For no_dims, you can also specify a number between 0 and 1, determining 
% the amount of variance you want to retain in the PCA step.
% The function returns the locations of the embedded trainingdata in 
% mappedX. Furthermore, it returns information on the mapping in mapping.
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

    if ~exist('no_dims', 'var')
        no_dims = 2;
    end
	
	% Make sure data is zero mean
    mapping.mean = mean(X, 1);
	X = X - repmat(mapping.mean, [size(X, 1) 1]);

	% Compute covariance matrix
	C = cov(X);
	
	% Perform eigendecomposition of C
	C(isnan(C)) = 0;
	C(isinf(C)) = 0;
    [M, lambda] = eig(C);
    
    % Sort eigenvectors in descending order
    [lambda, ind] = sort(diag(lambda), 'descend');
	M = M(:,ind(1:no_dims));
	
	% Apply mapping on the data
	mappedX = X * M;%降维后的X
	
    % Store information for out-of-sample extension
    mapping.M = M;%映射的基
	mapping.lambda = lambda;
    