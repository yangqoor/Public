% This function extracts the alpha of a vector X when the cluster centers
% are A, B, respectively.
% input : X = 3 x N vector
%         A = 3 x 1 vector
%         B = 3 x 1 vector

function [alpha, distProj] = alphaExtract(X, A, B)

norm = (B-A)'*(B-A);
N = size(X, 2);
alpha = (B-A)'*(repmat(B, [1, N]) - X)/norm;

XProj = repmat(A,[1, size(alpha, 2)]).*(repmat(alpha, [size(A, 1),1])) + ...
    repmat(B,[1, size(alpha, 2)]).*(1-repmat(alpha, [size(B, 1),1]));

normABMax = max(sqrt(sum(A.^2)), sqrt(sum(B.^2)));
distProj = sqrt(sum((X - XProj).^2, 1))/normABMax;