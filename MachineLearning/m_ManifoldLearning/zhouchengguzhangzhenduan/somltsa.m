function mappedX = somltsa(X,no_dims,ni,eig_impl )
  
   if ~exist('eig_impl', 'var')
     eig_impl = 'Matlab';
    end
    n = size(X, 1);
    %%计算局部切空间
    m = length(ni); 
    Bi = cell(1, m); 
   for i = 1 : n
       A(i) = i ;
   end
       
for i  = 1 : m 
     % k = length( ni{m} ) ; 
     % Compute correlation matrix W
            Ii = [] ;
            Ii = ni{i} ;
            Ii = Ii(Ii ~= 0);
            kt = numel(Ii);
            Xi = X(Ii,:) - repmat(mean(X(Ii,:), 1), [kt 1]);
            W = Xi * Xi'; 
            W = (W + W') / 2;
           % Compute local information by computing d largest eigenvectors of W
        [Vi, Si] = schur(W);
        [s, Ji] = sort(-diag(Si));
		if length(Ji) < no_dims
			no_dims = length(Ji);
			warning(['Target dimensionality reduced to ' num2str(no_dims) '...']);
		end
        Vi = Vi(:,Ji(1:no_dims));  
        % Store eigenvectors in G (Vi is the space with the maximum variance, i.e. a good approximation of the tangent space at point Xi)
		% The constant 1/sqrt(kt) serves as a centering matrix
		Gi = double([repmat(1 / sqrt(kt), [kt 1]) Vi]);
		% Compute Bi = I - Gi * Gi'
		Bi{i} = eye(kt) - Gi * Gi';           
  end
 % Construct sparse matrix B (= alignment matrix)
% disp('find Li')
% Li = cell(1,m); 
% for i = 1 : m
%     Ii = [] ;
%     Ii = ni{i} ;
%     k = length(Ii); b = zeros(n,k); 
%     for j = 1 : k
%       b(Ii(j),j) = 1;
%     end
%     Li{i} = b;
% end
%  B = zeros(n,n);
% for i = 1 : m
%   A =  Li{i} * Bi{i} * Bi{i}' * Li{i}';
%   B = B + A;
% end

 disp('Construct alignment matrix...');
 B = speye(n); %%% Li * B * Bt * lit
    for i=1:m
        Ii = [] ;
        Ii = ni{i} ;
        a = Ii(1);
        Ii = Ii(Ii ~= 0);
        B(Ii, Ii) = B(Ii, Ii) + Bi{i};							% sum Bi over all points
    end
    for i = 1 : n
       	B(i, i) = B(i, i) - 1; 
    end
    
 B = (B + B') / 2;											% make sure B is symmetric
    
	% For sparse datasets, we might end up with NaNs in M. We just set them to zero for now...
	B(isnan(B)) = 0;
	B(isinf(B)) = 0;
    
    % Perform eigenanalysis of matrix B
	disp('Perform eigenanalysis...');
    tol = 0;
	if strcmp(eig_impl, 'JDQR')
        options.Disp = 0;
        options.LSolver = 'bicgstab';
        [mappedX, D] = jdqr(B, no_dims + 1, tol, options);      % only need bottom (no_dims + 1) eigenvectors
    else
        options.disp = 0;
        options.isreal = 1;
        options.issym = 1;
        [mappedX, D] = eigs(B, no_dims + 1, tol, options);      % only need bottom (no_dims + 1) eigenvectors
    end

    % Sort eigenvalues and eigenvectors
    [D, ind] = sort(diag(D), 'ascend');
    mappedX = mappedX(:,ind);

    % Final embedding coordinates
	if size(mappedX, 2) < no_dims + 1, no_dims = size(mappedX, 2) - 1; end
    mappedX = mappedX(:,2:no_dims + 1);
    

   
    
 

