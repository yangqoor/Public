% INys_MDS.m implments the multidimensional scaling using the improved nystrom
% low rank approximation.

%Input:
% data: n-by-dim data matrix;
% m: number of landmark points;

%Output:
% X: n-by-m embedding results.

function X = INys_MDS(data, m);

[n,dim] = size(data);
[idx, center, m] = eff_kmeans(data, m, 5); %#ite is restricted to 5

%% random sampling
% dex = randperm(n);
% center = data(dex(1:m),:);

E = sqdist(data', center');
W = sqdist(center', center');
[xx, ldk_dex] = min(sqdist(data', center'));
pinvW = pinv(W);

mK = (E * (pinvW * (E' * ones(n,1)))) / n;
mmK = mean(mK);
mE = mK(ldk_dex);

EK = E * pinvW * E(ldk_dex,:)';
E = -EK + repmat(mK, 1, m) + repmat(mE', n, 1) - mmK;
W = E(ldk_dex, :); 
W = (W + W')/2;

[Ve, Va] = eig(W);
va = diag(Va);
pos_dex = find(va > 1e-10);
Ve = Ve(:,pos_dex);
va = 1 ./ sqrt(va(pos_dex));
Va = sparse(diag(va));

G = E * Ve * Va;
[U, L] = eig(G'*G);
X = G * U;
[sorted_l, dex] = sort(diag(L), 'descend');
X = X(:,dex);