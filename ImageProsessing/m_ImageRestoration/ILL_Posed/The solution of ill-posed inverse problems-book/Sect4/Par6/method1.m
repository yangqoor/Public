function [z,dis,gam,gamw]=method1(A,u,U,V,sig,IL,X,y,w,alf);
% для Nonsatur
global meth

if meth==1;IA=1./(sig+alf);elseif meth==2;
IA=(1-(alf./(alf+sig)).^2)./(sig+1e-17);elseif meth==3;
IA=(1-exp(-sig./alf))./(sig+1e-17);elseif meth==4;p=2.9;
IA=(sig.^p)./(sig.^(p+1)+alf);
else end

z=X*diag(IA.*sqrt(sig))*U'*u;x=IL*z;dis=norm(A*z-u);gam=z'*z;gamw=x'*x;




