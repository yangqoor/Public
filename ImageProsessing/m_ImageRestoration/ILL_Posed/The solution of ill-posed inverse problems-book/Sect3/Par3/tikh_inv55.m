function [z,dis,gam,gamw]=Tikh_inv55(A,u,U,V,sig,X,y,w,alf,DDD);
% для SVD_vs_Direct


IA=1./(sig+alf);t=IA.*w;x=V*t;z=X*t;dis=norm(A*z-u);gam=z'*z;gamw=x'*x;
%v=-alf*X*(IA.*z);psi=v'*v;
%ur_psi=psi.*(1+(DDD)^2./sqrt(alf));%


