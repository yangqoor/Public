% LLE ALGORITHM (using K nearest neighbors)
%
% [Y] = lle(X,K,dmax)
%
% X = data as D x N matrix (D = dimensionality, N = #points)
%(D = 点的维数, N = 点数)
% K = number of neighbors(领域点的个数)
% dmax = max embedding dimensionality(最大嵌入维数)
% Y = embedding as dmax x N matrix

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Y] = lle(X,K,d)

[D,N] = size(X);
%D是矩阵的行数，N是矩阵的列数
fprintf(1,'LLE running on %d points in %d dimensions\n',N,D);


% STEP1: COMPUTE PAIRWISE DISTANCES & FIND NEIGHBORS 
%寻找邻居数据点
fprintf(1,'-->Finding %d nearest neighbours.\n',K);

X2 = sum(X.^2,1);
%矩阵X中的每个元素以2为指数求幂值，并且竖向相加
%if two point X=(x1,x2),Y=(y1,y2)
%than the distance between X and Y is sqtr((x1-y1) .^2+ (x2-y2).^2)
distance = repmat(X2,N,1)+repmat(X2',1,N)-2*X'*X; 
%repmat就是在行方向把X2复制成N份,列方向为1份
[sorted,index] = sort(distance);
%sort是对矩阵排序,sorted是返回对每列排序的结果,index是返回排
%序后矩阵中每个数在矩阵未排序前每列中的位置
neighborhood = index(2:(1+K),:);
%计算neighborhood（看distance定义理解）的时候，要记住X中N代表的是点数，D代
%表每个点得维数，把neighborhood进行sort后会找出每个点（用X的每列表示）最近的%K个列

% STEP2: SOLVE FOR RECONSTRUCTION WEIGHTS
%计算重构权
fprintf(1,'-->Solving for reconstruction weights.\n');

if(K>D) 
  fprintf(1,'   [note: K>D; regularization will be used]\n'); 
  tol=1e-3; % regularlizer in case constrained fits are ill conditioned
else
  tol=0;
end

W = zeros(K,N);
for ii=1:N
   z = X(:,neighborhood(:,ii))-repmat(X(:,ii),1,K); % shift ith pt to origin
   C = z'*z;                            % local covariance
   C = C + eye(K,K)*tol*trace(C);          % regularlization (K>D)
   W(:,ii) = C\ones(K,1);                  % solve Cw=1
   W(:,ii) = W(:,ii)/sum(W(:,ii));            % enforce sum(w)=1
end;

% STEP 3: COMPUTE EMBEDDING FROM EIGENVECTS OF COST MATRIX M=(I-W)'(I-W)
%计算矩阵M=(I-W)'(I-W)的最小d个非零特征值对应的特征向量
fprintf(1,'-->Computing embedding.\n');
% M=eye(N,N); % use a sparse matrix with storage for 4KN nonzero elements
M = sparse(1:N,1:N,ones(1,N),N,N,4*K*N); 
for ii=1:N
   w = W(:,ii);
   jj = neighborhood(:,ii);
   M(ii,jj) = M(ii,jj) - w';
   M(jj,ii) = M(jj,ii) - w;
   M(jj,jj) = M(jj,jj) + w*w';
end;

% CALCULATION OF EMBEDDING
options.disp = 0; options.isreal = 1; options.issym = 1; 
[Y,eigenvals] = eigs(M,d+1,0,options);
%[Y,eigenvals] = jdqr(M,d+1);%change in using JQDR func
Y = Y(:,2:d+1)'*sqrt(N); % bottom evect is [1,1,1,1...] with eval 0


fprintf(1,'Done.\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% other possible regularizers for K>D
%   C = C + tol*diag(diag(C));                   % regularlization
%   C = C + eye(K,K)*tol*trace(C)*K;            % regularlization
