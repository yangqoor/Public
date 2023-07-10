function [T,B,idxNN] = ltsa(X,k,d)
    Tree = createns(X,'NSMethod','kdtree');
    
    idxNN = knnsearch(Tree,X,'K',k);
    
    N = size(X,1);
    
    B = 0.1*speye(N,N);
    
    for i = 1:N
        disp(i);
        Xij = X(idxNN(i,:),:)'*(eye(k)-ones(k,k)/k);
        [U,S,V] = svd(Xij);
        Qi = U(:,1:d);
        Ti = Qi'*Xij;
        Wi = (eye(k)-ones(k,k)/k)*(eye(k)-pinv(Ti)*Ti);
        %[H,R] = qr(Ti');
        %G = [ones(k,1)/sqrt(1.0*k),H];
        B(idxNN(i,:),idxNN(i,:)) = B(idxNN(i,:),idxNN(i,:))+Wi;
    end
    
    [T,D] = eigs(B,d+1,0);
    T = T(:,2:end);
    
end