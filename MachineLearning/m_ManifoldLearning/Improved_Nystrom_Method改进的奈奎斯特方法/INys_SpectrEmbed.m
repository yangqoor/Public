% Improved Nystrom method for Spectral Embedding
% This function implements the improved Nystrom method in <Improved Nystrom
% Low Rank Approximation and Error Analysis>, which can be used for Laplacian 
% Eigenmap, Spectral Clustering, or Normalized cut.

% Input:
% data: n-by-dim data matrix;
% kernel: a struct with two elements;
%         kernel.type: 'pol' or 'rbf';
%         kernel.para: d in the polynomial kernel <x,y>^d;
%                      b in the rbf kernel exp(-||x||^2/b);
% m: number of landmark points, ucually chosen much smaller than data size n.

% Output:
% V: n-by-m matrix, containing the top m eigenvectors of the normalized kernel matrix 
% D^(-0.5) * K * D^(-0.5), and these eigenvectors are further normalized by D^{-1/2} as
% in the normalized cut method; here K is the kernel matrix and D is the degree matrix. 
% The eigenvectors are sorted in descending order by corresponding eigenvalues.
% *note* you might want to re-scale each column of V for further processing

function V = INys_SpectrEmbed(data, kernel, m);

[n, dim] = size(data);
[idx, center, m] = eff_kmeans(data, m, 5); %#ite is restricted to 5

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

G = E * W^(-1/2);
d = G * (G' * ones(n,1));
d(find(d < 0)) = 1e-5;
d = d.^(-0.5);
sd = sparse(n, n);
for i = 1:n;
    sd(i,i) = d(i);
end;
G = sd * G;
[U, L] = eig(G'*G);
va = diag(L);
[va, dex] = sort(va,'descend');
U = U(:,dex);
V = G * U;
V = sd * V;
