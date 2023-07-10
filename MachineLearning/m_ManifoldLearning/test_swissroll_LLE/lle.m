% LLE ALGORITHM (using K nearest neighbors)
%
% [Y] = lle(X,K,dmax)
%
% X = data as D x N matrix (D = dimensionality, N = #points)
%(D = ���ά��, N = ����)
% K = number of neighbors(�����ĸ���)
% dmax = max embedding dimensionality(���Ƕ��ά��)
% Y = embedding as dmax x N matrix

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Y] = lle(X,K,d)

[D,N] = size(X);
%D�Ǿ����������N�Ǿ��������
fprintf(1,'LLE running on %d points in %d dimensions\n',N,D);


% STEP1: COMPUTE PAIRWISE DISTANCES & FIND NEIGHBORS 
%Ѱ���ھ����ݵ�
fprintf(1,'-->Finding %d nearest neighbours.\n',K);

X2 = sum(X.^2,1);
%����X�е�ÿ��Ԫ����2Ϊָ������ֵ�������������
%if two point X=(x1,x2),Y=(y1,y2)
%than the distance between X and Y is sqtr((x1-y1) .^2+ (x2-y2).^2)
distance = repmat(X2,N,1)+repmat(X2',1,N)-2*X'*X; 
%repmat�������з����X2���Ƴ�N��,�з���Ϊ1��
[sorted,index] = sort(distance);
%sort�ǶԾ�������,sorted�Ƿ��ض�ÿ������Ľ��,index�Ƿ�����
%��������ÿ�����ھ���δ����ǰÿ���е�λ��
neighborhood = index(2:(1+K),:);
%����neighborhood����distance������⣩��ʱ��Ҫ��סX��N������ǵ�����D��
%��ÿ�����ά������neighborhood����sort����ҳ�ÿ���㣨��X��ÿ�б�ʾ�������%K����

% STEP2: SOLVE FOR RECONSTRUCTION WEIGHTS
%�����ع�Ȩ
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
%�������M=(I-W)'(I-W)����Сd����������ֵ��Ӧ����������
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
