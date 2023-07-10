function [Y,idxNN] = lle(X,k,d)
    Tree = createns(X,'NSMethod','kdtree');
    
    idxNN = knnsearch(Tree,X,'K',k+1);
    idxNN = idxNN(:,2:end);
    
    N = size(X,1);
    
    W = sparse(N,N);
    
    for i = 1:N
        disp(i);
        Xij = X(idxNN(i,:),:)'-repmat(X(i,:)',[1,k]);
        w = sum(pinv(Xij'*Xij),2); 
        W(i,idxNN(i,:)) = w'/sum(w);
    end
    
    M = speye(N)-W-W'+W'*W;
    [Y,D] = eigs(M,d+1,0);
end