function [mappedX, mapping] = lle(X, no_dims, k, eig_impl)
%LLE Runs the locally linear embedding algorithm
%
%   mappedX = lle(X, no_dims, k, eig_impl)
%
% Runs the local linear embedding algorithm on dataset X to reduces its
% dimensionality to no_dims. In the LLE algorithm, the number of neighbors
% can be specified by k. 
% The function returns the embedded coordinates in mappedX.
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

    if ~exist('no_dims', 'var')
        no_dims = 2;
    end
    if ~exist('k', 'var')
        k = 12;
    end
    if ~exist('eig_impl', 'var')
        eig_impl = 'Matlab';
    end

    % Get dimensionality and number of dimensions
    [n, d] = size(X);

    % Compute pairwise distances and find nearest neighbours (vectorized implementation)
    disp('Finding nearest neighbors...');    
    if ~ischar(k)
        [distance, neighborhood] = find_nn(X, k + 1);
        neighborhood = neighborhood(:,2:k+1);
        max_k = k;
    else
        [distance, neighborhood] = find_nn(X, k);
        max_k = size(neighborhood, 2);
    end
    if nargout > 1
        mapping.nbhd = distance;
    end
    X = X';
    neighborhood = neighborhood';
        
    % Find reconstruction weights for all points by solving the MSE problem 
    % of reconstructing a point from each neighbours. A used constraint is 
    % that the sum of the reconstruction weights for a point should be 1.
    disp('Compute reconstruction weights...');
    if k > d 
        tol = 1e-5;
    else
        tol = 0;
    end

    % Construct reconstruction weight matrix
    W = zeros(max_k, n);
    for i=1:n
        nbhd = neighborhood(:,i);
        if ischar(k)
           nbhd = nbhd(nbhd ~= 0);
        end
        kt = numel(nbhd);
        z = X(:,nbhd) - repmat(X(:,i), 1, kt);                  % Shift point to origin
        C = z' * z;												% Compute local covariance
        C = C + eye(kt, kt) * tol * trace(C);					% Regularization of covariance (if K > D)
        wi = C \ ones(kt, 1);                                   % Solve linear system
        wi = wi / sum(wi);                                      % Make sure that sum is 1
        W(:,i) = [wi; nan(max_k - kt, 1)];
    end

    % Now that we have the reconstruction weights matrix, we define the 
    % sparse cost matrix M = (I-W)'*(I-W).
    M = sparse(1:n, 1:n, ones(1, n), n, n, 4 * max_k * n);
    for i=1:n
       w = W(:,i);
       w = w(~isnan(w));
       j = neighborhood(:,i);
       j = j(j ~= 0);
       M(i, j) = M(i, j) - w';
       M(j, i) = M(j, i) - w;
       M(j, j) = M(j, j) + w * w';
    end
	
	% For sparse datasets, we might end up with NaNs or Infs in M. We just set them to zero for now...
	M(isnan(M)) = 0;
	M(isinf(M)) = 0;
    
    % The embedding is computed from the bottom eigenvectors of this cost matrix
	disp('Compute embedding (solve eigenproblem)...');
    tol = 0;
    if strcmp(eig_impl, 'JDQR')
        options.Disp = 0;
        options.LSolver = 'bicgstab';
        [mappedX, eigenvals] = jdqr(M, no_dims + 1, tol, options);
    else
        options.disp = 0;
        options.isreal = 1;
        options.issym = 1;
        [mappedX, eigenvals] = eigs(M, no_dims + 1, tol, options);          % only need bottom (no_dims + 1) eigenvectors
    end
    [eigenvals, ind] = sort(diag(eigenvals), 'ascend');
    if size(mappedX, 2) < no_dims + 1
		no_dims = size(mappedX, 2) - 1;
		warning(['Target dimensionality reduced to ' num2str(no_dims) '...']);
    end
    mappedX = mappedX(:,ind(2:no_dims + 1));                                % throw away zero eigenvector/value					

