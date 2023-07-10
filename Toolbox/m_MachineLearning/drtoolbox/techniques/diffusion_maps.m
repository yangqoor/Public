function mappedX = diffusion_maps(X, no_dims, sigma)
%DIFFUSION_MAPS Runs the diffusion map algorithm
%
%   mappedX = diffusion_maps(X, no_dims, sigma)
%
% The functions runs the diffusion map algorithm on dataset X to reduce it 
% to dimensionality no_dims. The variable sigma is the variance of the Gaussian
% used in the affinity computation (default = 1). The variable alpha
% determines the operator that is applied on the graph (default = 1).
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
    if ~exist('sigma', 'var')
        sigma = 1;
    end
    
    % Make data zero-mean, unit variance
    X = X - repmat(mean(X, 1), [size(X, 1) 1]);
    X = X ./ repmat(var(X, 1), [size(X, 1) 1]);

    % Compute Gaussian kernel
    if size(X, 1) < 3000
        disp('Computing forward transition Markov matrix...');
        D = squareform(pdist(X, 'euclidean'));
        M = exp(-((D.^2 / (2 * sigma)) .^ 2));
        clear D;
        
        % Normalize in order to create Markov transition matrix (note that
        % the graph operator alpha is actually not used)
        p = sqrt(sum(M, 1));
        M = M ./ (p * p');
       
        % Compute largest eigenvectors of Markov matrix
        disp('Performing eigendecomposition...');

        % If sigma is high, we have a lot of almost zeros -> sparse eigendecomposition
        if sigma >= 1
            % Make matrix sparse by thresholding
            maximum = max(max(M));
            M = sparse(M .* double(M > (1e-9 * maximum)));

            % Eigenanalysis
            options.disp = 0;
            options.isreal = 0;
            options.issym = 0;
            [mappedX, val] = eigs(M, no_dims + 1, 'LM', options);

        % Else run the normal O(N^3) eigendecomposition
        else
            [mappedX, val] = eig(M);
        end
        
    % Run implementation without explicitly computing Gaussian kernel
    else
        disp('Eigenanalysis of kernel matrix (using slower but memory-conservative implementation)...');
        options.disp = 0;
        options.isreal = 1;
        options.issym = 1;
        [mappedX, val] = eigs(@(v)kernel_function(v, X', 0, 'gauss', sigma), size(X, 1), no_dims + 1, 'LM', options);
    end
    
    % Sort eigenvectors in descending order and select largest nontrivial eigenvalues 
    [val, ind] = sort(diag(val), 'descend');
	mappedX = mappedX(:,ind(2:no_dims + 1));
    val = val(2:no_dims + 1);

    % Normalize eigenvectors by their eigenvalue to obtain embedding
    mappedX = mappedX .* repmat(val', [size(mappedX, 1) 1]);

    