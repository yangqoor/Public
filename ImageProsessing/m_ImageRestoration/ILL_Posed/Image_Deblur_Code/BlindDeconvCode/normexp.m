function p=normexp(logp)
    [n,m]=size(logp);
    logp=logp-max(logp,[],2)*ones(1,m);
    p=exp(logp);
    p=p./(sum(p,2)*ones(1,m));
    
    