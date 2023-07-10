% Samuel Rivera
% Oct 29, 2010
% X in pxN, N samples
% calculate the pairwise distance matrix

function [ aveDist allDist ] = calcPairwiseDistances( X )

nAll = size(X,2);

A = X'*X;
dA = diag(A);
DD = repmat(dA,1,nAll) + repmat(dA',nAll,1) - 2*A;

%get all entries in upper diagonal, eliminating the diagonal entries
allDist = [];
for i1 = 1:nAll-1
    dtemp = DD(i1, i1+1:end);
    allDist = [ allDist; dtemp(:)];
    
end

aveDist = mean(allDist);

