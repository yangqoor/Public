function[result] = gram_schmidt(varargin)
    % MATLAB implementation of Classical Gram-Schmidt Algorithm.

    % Convert input arguments into A.
    A_raw = cellfun(@transpose, varargin, 'UniformOutput', false);  
    A = cell2mat(A_raw);
    
    % Initialise the first column vector of V to be the first column 
    % vector of A.
    V(:,1) = A(:, 1);
    
    % Normalise the first column vector of V to become the first column
    % vector of Q.
    Q(:,1) = V(:,1) / norm(V(:,1));
    
    % Initialise the rest of the columns of the Q matrix.
    for i=2:nargin,
        V(:,i) = A(:, i) - sum(A, Q, i);
        Q(:,i) = V(:, i) / norm(V(:,i));
    end
    result = Q;
end

function[result] = sum(A, Q, i)
    R = zeros(size(A, 1), 1);
    for j=1:i-1,
        R = R + dot(A(:,i), Q(:,j)) * Q(:,j);
    end    
    result = R;
end