function [Y,idxNN] = isomap(X,K,d)
    Tree = createns(X,'NSMethod','kdtree');
    
    idxNN = knnsearch(Tree,X,'K',K+1);
    idxNN = idxNN(:,2:end);
    
    N = size(X,1);
    
    W = inf*ones(N,N);
    A = zeros(N,N);
    
    for i = 1:N
        disp(i);
        for k = 1:K
            W(i,idxNN(i,k)) = norm(X(i,:)-X(idxNN(i,k),:));
            A(i,idxNN(i,k)) = 1;
            A(idxNN(i,k),i) = 1;
        end
    end
    
    D = floyd_warshall(min(W,W'));
    J = eye(N)-ones(N,N)/N;
    [Y,E] = eig(-0.5*J*(D.^2)*J);
    Y = Y(:,2:d+1);
end