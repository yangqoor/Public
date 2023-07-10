function Y = sne(X, d)
%SNE Implementation of Stochastic Neighbor Embedding
%
%   Y = sne(X, d)
%
% Runs the traditional implementation of Stochastic Neighbor Embedding 
% algorithm. The high-dimensional datapoints are specified by X. The target
% dimensionality if specified in d. The function returns the embedded 
% points in Y.
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
    N = size(X, 1);                 % number of instances
    sigma = 1;                      % variance of Gaussian kernel
    epsilon = 1e-9;                 % stop condition
    tol = 10e-7;                    % regularlization parameter
    eta = .5;                       % learning rate
    max_iter = 4000;                % maximum number of iterations
    finished = 0;
    iter = 0;
    J = 1;

    % Initialize embedding coordinates randomly (close to origin)
    Y = rand(N, d) * .01;
    dJ = zeros(size(Y, 1), d);
    
    % Probability computations for the high-dimensional space
    % Compute distance matrix
    D = squareform(pdist(X, 'euclidean')) .^ 2;
    D = D ./ max(max(D));
    % Compute scaled Euclidian distances (for neighbors only)
    D = D ./ (2 * sigma.^2);
    % Compute probablity that xi would pick xj as neighbour
    P = exp(-D) ./ repmat(sum(exp(-D), 2) - 1, 1, N);
    P(1:N+1:end) = 0;
	P(isnan(P)) = 0;
	P(isinf(P)) = 0;
    % Store values where P ~= 0
    indP = find(P ~= 0);

    % Iterating loop
    while ~finished

        % Probability computations for the low-dimensional space
        % Compute distance matrix (can be done more efficient, viz. only for k neighbors)
        D = squareform(pdist(Y, 'euclidean')) .^ 2;
        D = D ./ max(max(D));
        % Compute probability that yi would pick yj as neighbour 
        % In this formula, the variance is set to .5
        Q = exp(-D) ./ (repmat(sum(exp(-D), 2) - 1, 1, N));
		Q(isnan(Q)) = 0;
		Q(isinf(Q)) = 0;
        Q(1:N+1:end) = 0;
        
        % Compute cost function between P and Q
        if rem(iter - 1, 10) == 0
            oldJ = J;
            indQ = indP(find(Q(indP) ~= 0));                                    % find values where P ~= 0 and Q ~= 0
            J = sum(sum(P(indQ) .* log10(P(indQ) ./ (Q(indQ) + tol)))) / N;     % N term normalizes for # of datapoints
            disp(['Current error: ' num2str(J)]);
            if abs(oldJ - J) < epsilon & iter > 100, finished = 1; end
			if isnan(J), finished = 1; end
        end
        
        % Compute gradient of J
        PQ = P - Q + P' - Q';
        for i=1:N
            dJ(i,:) = sum((repmat(Y(i,:), N, 1) - Y) .* repmat(PQ(i,:)', 1, d), 1);        
        end
     
        % Steepest descent
        Y = Y - eta * dJ;
		
		% Normalize Y (in order to prevent very large coordinates)
		Y = Y / max(max(Y));
        
        % Add some Gaussian noise (reduce jitter over time)
        Y = Y + (randn(size(Y)) * (.3 - iter * (.3 / max_iter)));
        
        % Display information and stop condition
        iter = iter + 1;
        disp(['Iteration ' num2str(iter) '...']);
        %if rem(iter - 1, 5) == 0, scatter(Y(:,1), Y(:,2), 5, X(:,3)); pause(.25); end
        if iter == max_iter, finished = 1; end
    end
    