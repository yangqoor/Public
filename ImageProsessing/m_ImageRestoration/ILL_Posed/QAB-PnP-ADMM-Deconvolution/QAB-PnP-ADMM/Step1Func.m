function [f, df] = Step1Func(x,param)

    polyApproxThr=10^-10;
    x=double(x);
    H=param.H;
    Ht=param.Ht;
    lambda=double(param.lambda);
    Y=double(param.Y);
    V=double(param.V);
    U=double(param.U);
    
    Hx=H(x);
    apprIdx=find(Hx<polyApproxThr);
    lnIdx=find(Hx>=polyApproxThr);
      
    [n,~] = size(Hx);
    a=-1/(2*polyApproxThr^2);
    b=2/(polyApproxThr);
    c=log(polyApproxThr)-1.5;
    
    fLn = -(Y(lnIdx))'*log(Hx(lnIdx));
    if(isempty(fLn))
        fLn=0;
    end
    
    fPolyApprox=-Y(apprIdx)'*( a*(Hx(apprIdx)).^2+b*Hx(apprIdx)+c );
    if(isempty(fPolyApprox))
        fPolyApprox=0;
    end
    f=fLn+fPolyApprox+sum(Hx(Hx>=0))+lambda/2*(norm(x-V+U))^2;
    
    if nargout > 1
      du=zeros(n,1);
      du(lnIdx)=-Y(lnIdx)./Hx(lnIdx);
      du(apprIdx)=-Y(apprIdx).*(2*a*Hx(apprIdx)+b);      
      
      indicator=ones(n,1);
      indicator(Hx<0)=0;
      
      df=Ht(du+indicator)+lambda*(x-V+U);
    end

%     if nargout > 2
%       d2u=zeros(size(Y));
%       d2u(lnIdx)=Y(lnIdx)./(Hx(lnIdx)).^2;
%       d2u(apprIdx)=-Y(apprIdx)*(2*a);      
%       ddf=H'*diag(d2u)*H+lambda*eye(size(x,1));
%     end
end
