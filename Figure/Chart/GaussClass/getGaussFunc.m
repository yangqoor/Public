function func=getGaussFunc(Mu,Sigma,Pi)
[K,D]=size(Mu);

X{D}=[];
for d=1:D
    X{d}=['x',num2str(d)];
end
X=sym(X);

func=0;
for k=1:K
    tMu=Mu(k,:);
    tSigma=Sigma(:,:,k);   
    tPi=Pi(k);
    tX=X-tMu;   
    func=func+tPi*(1/(2*pi)^(D/2))*(1/det(tSigma)^(1/2))*exp((-1/2)*(tX/tSigma*tX.'));
end

func=matlabFunction(func);
end