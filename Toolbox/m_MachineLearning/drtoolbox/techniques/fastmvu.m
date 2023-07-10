function mappedX = fastmvu(X, no_dims, k, eig_impl);
%FAST_MVU Runs the Fast Maximum Variance Unfolding algorithm
%
%   [mappedX, details] = fastmvu(X, no_dims, k)
%
% Computes a low dimensional embedding of data points using the Fast
% Maximum Variance Unfolding algorithm. The data is specified in an NxD 
% data matrix X.
% The lowdimensional representation is returned in mappedX.
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
    if ~exist('k', 'var')
        k = 12;
    end
    if ~exist('eig_impl', 'var')
        eig_impl = 'Matlab';
    end

    % Initialize some parameters
    maxiter = 10000;                    % maximum number of iterations
    eta = 1e-5 ;                        % regularization parameter
    initial_dims = 4 * no_dims;         % dimensionality of first guess
    
    % Compute sparse distance matrix D on dataset X
    disp('Constructing neighborhood graph...');
    D = find_nn(X, k);
    D = D .^ 2;
    D = D ./ max(max(D));
    
    % Check whether the neighborhood graph is connected
    blocks = components(D)';
    if max(blocks) > 1
        error('The neighborhood graph is not connected, causing a maximization of a function without upper bound.');
    end
    clear blocks

    % Perform eigendecomposition of the graph Laplacian
    disp('Perform eigendecomposition of graph Laplacian...');
    DD = diag(sum(D, 2));                       % degree matrix
    L = DD - D;                                 % Laplacian
    L(isnan(L)) = 0; DD(isnan(DD)) = 0;
	L(isinf(L)) = 0; DD(isinf(DD)) = 0;
    if strcmp(eig_impl, 'jdqr')
        options.Disp = 0;
        options.LSolver = 'bicgstab';
        [laplX, lambda] = jdqr(L, no_dims + 1, eta, options);               % only need bottom (initial_dims + 1) eigenvectors
    else
        options.disp = 0;
        options.isreal = 1;
        options.issym = 1;
        [laplX, lambda] = eigs(L, initial_dims + 1, eta, options);			% only need bottom (initial_dims + 1) eigenvectors
    end
    [lambda, ind] = sort(diag(lambda), 'ascend');
    laplX = laplX(:,ind(2:initial_dims + 1));
    clear DD L

    % Maximize sum of pairwise distances while retaining distances inside
    % neighborhood graph distances. I.e. perform SDP optimization, starting
    % with eigendecomposition of the Laplacian. The constraints of the 
    % optimization are formed by the upper triangle of D.
    disp('Perform semi-definite programming...');
    disp('CSDP OUTPUT =============================================================================');
    try 
        [foo1, mappedX] = sdecca2(laplX', triu(D), eta, 0);
    catch
        error('Error while performing SDP. Maybe the binaries of CSDP are not suitable for your platform.');
    end
    disp('=========================================================================================');
    
    % Perform initial conjugate gradient search (in initial-dimensional space)
    disp('Finetune initial solution using conjugate gradient descent...');
    mappedX = hillclimber2c(D, mappedX, 'maxiter', maxiter, 'eta', eta);

    % Perform PCA to remove noise and further reduce dimensionality
    disp('Perform PCA to obtain final solution...');
    mappedX = pca(mappedX', no_dims);
    mappedX = mappedX';

    % Computing final solution
    disp('Finetune final solution using conjugate gradient descent...');
    mappedX = hillclimber2c(D, mappedX, 'maxiter', maxiter, 'eta', 0);
    mappedX = mappedX';
    
