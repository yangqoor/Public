function mappedX = llc(X, neighbor, no_dims, R, Z, eig_impl)
%LLC Runs the LLC algorithm (given information on the formed factor analyzers)
%
%   mappedX = llc(X, k, no_dims, R, Z, eig_impl)
%
% Runs the LLC algorithm (given information on the formed factor
% analyzers). The variable X contains the dataset (transposed), and
% neighbor contains the neighborhood indices for every datapoint. The
% matrices R and Z indicate repectively the responsisbiities of clusters to
% points and the cluster centers. The variable eig_impl determines the
% eigenanalysis method that is used. Possible values are 'Matlab' and
% 'JDQR' (default = 'Matlab').
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

    if ~exist('eig_impl', 'var')
        eig_impl = 'Matlab';
    end
    
    % Initialize some variables
    [no_dims N no_analyzers] = size(Z);
    if numel(neighbor) == 1 
        nn = neighbor;
    else
        nn = size(neighbor, 1);
    end
    kf = no_analyzers * (no_dims + 1);
    
    % Compute pairwise distances and store neighbor indices
    disp(['Find ' num2str(nn) ' nearest neighbors...']);
    [foo, neighbor] = find_nn(X', nn + 1);
    neighbor = double(neighbor');
    neighbor = neighbor(2:nn + 1,:);

    % Solve for reconstruction weights of the datapoints
    disp('Solving for reconstruction weights...');
    tol = 1e-5;
    W = zeros(nn, N);
    for ii=1:N
       z = X(:,neighbor(:,ii)) - X(:,ii * ones(nn, 1));     % shift ith pt to origin
       C = z' * z;                                          % local covariance
       C = C + eye(nn, nn) * tol * trace(C);                % regularlization (n > D)
       W(:,ii) = C \ ones(nn, 1);                           % solve Cw=1
       W(:,ii) = W(:,ii) / sum(W(:,ii));                    % enforce sum(w)=1
    end

    % Compute embedding from bottom eigenvectors of cost matrix M=(I-W)'(I-W)
    disp('Computing lowdimensional embeddings...');
    M = sparse(1:N, 1:N, ones(1, N), N, N, 4 * nn * N);
    for i=1:N
       w = W(:,i);
       j = neighbor(:,i);
       M(i, j) = M(i, j) - w';
       M(j, i) = M(j, i) - w;
       M(j, j) = M(j, j) + w * w';
    end

    % Adds last entry = 1 in posterior mean to handle means of factor analyzers
    Z(no_dims + 1,:,:) = 1;
    Z = permute(Z, [1 3 2]);

    % Construct responsibility weighted local representation matrix U
    R = reshape(R, [1 no_analyzers N]);
    U = reshape(repmat(R, [no_dims + 1 1 1]) .* Z, [kf N])';
    
    % Construct generalized eigenproblem A*LY = lambda*B*LY
    A = M' * U;
    A = A' * A;
    B = U' * U;

    % Eigenanalysis of generalized eigenproblem
    if condest(A) > 1e5 || condest(B) > 1e5
        warning('Matrix badly scaled: results may be inaccurate. Maybe you should use more iterations in the EM-algorithm. Using a lower number of factor analyzers might overcome this problem.');
    end
    if strcmp(eig_impl, 'JDQR')
        options.Disp = 0;
        options.LSolver = 'bicgstab';
        [LY, evals] = jdqz(A, B, no_dims + 1, 'SM', options);
    else
        options.disp = 0; 
        options.isreal = 1; 
        options.issym = 1;
        [LY, evals] = eigs(A, B, no_dims + 1, 'SM', options);
    end
    
    % Sort eigenvectors and eigenvalues in ascending order
    [evals, ind] = sort(diag(evals), 'ascend');
    LY = LY(:,ind(2:end));
    
    % Normalize eigenvectors
    s = sqrt(diag(LY' * B * LY) / N)';
    LY = LY ./ repmat(s, [kf 1]);                      % normalize LY so that cov(mappedX) = I

    % Final lowdimensional data representation
    mappedX = (U * LY)';

