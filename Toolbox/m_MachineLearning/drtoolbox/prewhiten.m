function X = prewhiten(X, alfa)
%PREWHITEN Performs prewhitening of a dataset X
%
%   X = prewhiten(X)
%   X = prewhiten(X, alfa)
%
% Performs prewhitening of the dataset X. Prewhitening concentrates the main
% variance in the data in a relatively small number of dimensions. Thereby, 
% it separates noise from the data. Therefore, prewhitening is recommended 
% before performing any dimensionality reduction. The variable alfa is a value 
% between 0 and 1 that specifies the amount of variance that is contained 
% in the prewhitened data (default = 0.95). Note that prewhitening may
% reduce the number of dimensions in the dataset.
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

    if ~exist('alfa', 'var')
        alfa = 0.95;
    end
    
    % Handle PRTools dataset
    if strcmp(class(X), 'dataset')
        prtools = 1;
        XX = X;
        X = X.data;
    else 
        prtools = 0;
    end

    % Perform PCA
    [X, mapping] = pca(X, size(X, 2));

    % Evaluate eigenvalues
    mapping.lambda = mapping.lambda / sum(mapping.lambda);
    d = 0; s = 0;
    while s < alfa
        d = d + 1;
        s = s + mapping.lambda(d);
    end
    
    % Select only dimensions that contain most variance
    X = X(:,1:d);
    
    % Handle PRTools dataset
    if prtools == 1
        XX.data = X;
        X = XX;
    end
    