function k=resizeKer(k,ret,k1,k2)
    k=imresize(k,ret);
    k=max(k,0);
    k=fixsize(k,k1,k2);
    k=k/sum(k(:));