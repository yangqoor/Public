function mappedX = ica(X)
%ICA Perform Independent Component Analysis (ICA) on vector X
% 
%   mappedX = ica(X)
%
% Performs Independent Component Analysis (ICA) on vector X. The resulting
% components are returned in mappedX.
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

    disp('Extracting independent components...');

    % Compute product between square-root of inverse covariance matrix and zeromean data
    mappedX = sqrtm(inv(cov(X'))) * (X - repmat(mean(X, 2), 1, size(X, 2)));
    
    % Perform SVD of sum(Y.^2).*Y*Y
	[mappedX, ss, vv] = svd((repmat(sum(mappedX .* mappedX, 1), size(mappedX, 1), 1) .* mappedX) * mappedX');
