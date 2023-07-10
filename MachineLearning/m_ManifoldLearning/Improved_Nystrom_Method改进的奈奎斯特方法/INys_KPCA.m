% Improved Nystrom method for Kernel PCA
% This function implements the improved Nystrom method in <Improved Nystrom
% Low Rank Approximation and Error Analysis>, which is used for Kernel PCA.

% Input:
% data: n-by-dim data matrix;
% kernel: a struct with two elements;
%         kernel.type: 'pol' or 'rbf';
%         kernel.para: d in the polynomial kernel <x,y>^d;
%                      b in the rbf kernel exp(-||x||^2/b);
% m: number of landmark points, ucually chosen much smaller than data size n.

% Output:
% V: n-by-m matrix, containing the top m eigenvectors of the centered kernel matrix 
% HKH, where K is the kernel matrix and H the centering matrix. 
% The eigenvectors are sorted in descending order by corresponding eigenvalues.

function V = INys_KPCA(data, kernel, m);

[n, dim] = size(data);
[idx, center, m] = eff_kmeans(data, m, 5);%#ite is restricted to 5

%% random sampling
% dex = randperm(n);
% center = data(dex(1:m),:);


if(kernel.type == 'pol');
    W = center * center';
    E = data * center';
    W = W.^kernel.para;
    E = E.^kernel.para;
end;

if(kernel.type == 'rbf');
    W = exp(-sqdist(center', center')/kernel.para);
     E = exp(-sqdist(data', center')/kernel.para);
end;

E = E - repmat(mean(E), n, 1);
G = E * W^(-1/2);
[U,L] = eig(G'*G);
V = G * U;
[va, dex] = sort(diag(L),'descend');
V = V(:, dex);