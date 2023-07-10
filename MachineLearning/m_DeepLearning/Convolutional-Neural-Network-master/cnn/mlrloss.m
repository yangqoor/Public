function [nll, g, od, percent] = mlrloss(wb, X, y, K, gpu, prediction)
if gpu == 1
    X = single(X); y = double(y);
end

% wb is expected to be of length (N+1)*(K-1)
% Hence, a concatenated weights and bias

% N features M examples
% K distinct classes (1 to K)
[N,M] = size(X);
theta = reshape(wb(1:N*(K-1)), K-1, N);
bias  = reshape(wb((1+N*(K-1)):end), K-1, 1);

% I indexes into the correct target entries
I=full(sparse(y,1:M,1,K,M));

% Compute the values after the linear transform
W=[ bsxfun(@plus, theta * X, bias) ; zeros(1, M) ];

% This rescales so that all values are negative, hence, no overflow
% problems with the exp operation (a single +inf can blow things up)
W=bsxfun(@minus, W, max(W));
W=exp(W);

% Convert to Probabilities by normalizing
P=bsxfun(@rdivide, W, sum(W));

% Loss.
% P(logical(I)) == I.*P which basically extracts out the terms we want
nll=-full(sum(log(P(logical(I)))));
if prediction == 1
    [~, indices] = max(P);
    percent = sum(y-indices== 0) / length(y);    
else
    percent = 0;
end
% Compute the gradients
if (nargout >= 2)
    od = (P - I); % P-I gives exactly the error derivatives at the "output units"
    % after this theta' * od can be used as the backprop derivative
    % while od * X can be used as the derivative at the current layer
    gw = od * X';
    gw = gw(1:K-1,:); 
    gb = sum(od, 2);
    gb = gb(1:K-1,:);
    g = [gw(:) ; gb(:)];
end

% Compute the derivatives for backprop
if (nargout >= 3)
    % use this for backprop
    od = theta' * od(1:K-1,:);
end

end