function mappedX = mds(X, no_dims)
%MDS Run MDS on the data to get a low-dimensional visualization
% 
%   mappedX = mds(X, no_dims)
%
% Run multidimensional scaling on the dataset X to get a two-dimensional 
% visualization. The low-dimensional representation is returned in mappedX.
% It has dimensionality no_dims (default = 2).
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

	% Initialize some variables
	iterations = 30;			% Number of iterations
	lr = 0.05;					% Learning rate
	r = 2;						% Metric

	% Compute pairwise distance matrix
	disp('Computing dissimilarity matrix...');
	D = squareform(pdist(X, 'euclidean'));
	n = size(D, 1);
	
	% Normalise distances
	D = D / max(max(D));
	
	% Compute the variance of the distance matrix
	Dbar = (sum(sum(D)) - trace(D)) / n / (n - 1);
	temp = (D - Dbar * ones(n)) .^ 2;
	varD = .5 * (sum(sum(temp)) - trace(temp));

	% Initialize some more variables
	mappedX = rand(n, no_dims) * .01 - .005;
	dh = zeros(n);
	rinv = 1 / r;

	% Iterate
	disp('Running MDS...')
	for i=1:iterations
		fprintf('.');
		
		% Randomly permute the objects to determine the order in which they are pinned for this iteration
		pinning_order = randperm(n);
		for j=1:n
			m = pinning_order(j);
      
			% Move all of the other on each dimension according to the learning rule   
			indx = [1:m-1 m+1:n];                                                       
			pmat = repmat(mappedX(m,:), [n 1]) - mappedX;                                              
			dhdum = sum(abs(pmat) .^ r, 2) .^ rinv;
			dh(m, indx) = dhdum(indx)';
			dh(indx, m) = dhdum(indx);
			dhmat = lr * repmat((dhdum(indx) - D(m,indx)') .* (dhdum(indx) .^ (1 - r)), [1 no_dims]);
			mappedX(indx,:) = mappedX(indx,:) + dhmat .* abs(pmat(indx,:)) .^ (r - 1) .* sign(pmat(indx,:));
		end
	end
	
	disp(' ');
