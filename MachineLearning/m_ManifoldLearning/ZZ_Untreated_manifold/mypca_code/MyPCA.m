function [Lambda,U,meanX]=MyPCA(X)
%%
% Performs the extraction of the PCA components given a dataset 
% Input:    X, DxN matrix of N points x of dimension D 
% Output:   
%    Lambda : set of eigenvalues of the covariance matrix ranked in decreasing order
%    U      : matrix of eigenvectors (ranked in the same order than eigenvalues)
%    meanX  : average value of the datas in X
% 
%
X = X';
sizex = size(X);
meanX = mean(X);
%meanX
cov = zeros(sizex(2));
for i = 1:sizex(2)
    x1 = X(:,i);
    meanx1 = meanX(i);
    for j = i:sizex(2)
        x2 = X(:,j);
        meanx2 = meanX(j);
        value = ((x1-meanx1)'*(x2-meanx2))/(sizex(1)-1);
        cov(i,j) = value;
        cov(j,i) = value;
    end
end
%cov
[U,D] = eig(cov);
%U
%D
Lambda = diag(D);
%Lambda
for t= 1:sizex(2)
    for k = t+1:sizex(2)
        if Lambda(t)<Lambda(k)
            tmp = Lambda(t);
            Lambda(t) = Lambda(k);
            Lambda(k) = tmp;
            tmpU = U(:,t);
            U(:,t) = U(:,k);
            U(:,k) = tmpU;
        end
    end
end
    
