function w = nnegwls(X,y)
    XtX = X'*X;
    Xty = X'*y;
    
    [U,S,V] = svd(XtX);
    Si = diag(1.0/(diag(S)+sign(diag(S))*1e-5));
    
    w = rand(size(XtX,1),1);
    w = w / sum(w);
    
    mu = 1.0;

    n = size(X,2);
    
    for t = 1:100
        disp(t);
        for s = 1:10
            disp(s);
            Ai = pinv(ones(n,n) + diag(1.0*(w<0.0)));
            
            r1 = XtX*w-Xty;
            r2 = (sum(w)-1.0)+max(0.0,-w);
            
            Air1 = Ai*r1/mu;
            Air2 = Ai*r2;
            
            B = pinv(Si+V'*Ai*U/mu)*V';
            
            w = w-1e-3*(Air1-(1.0/mu)*Ai*U*B*Air1+Air2-Ai*U*B*V'*Air2/mu);
            w(w<0.0) = 0.0;
            w = w / sum(w);
        end
    end
end