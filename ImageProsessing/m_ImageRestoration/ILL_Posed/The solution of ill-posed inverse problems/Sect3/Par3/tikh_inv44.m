function [z,dis,gam,psi,ur_psi,gamw]=Tikh_inv44(A,u,U,V,sig,X,y,w,alf,DDD);
% для Comp_L_solutions


IA=1./(sig+alf);t=IA.*w;x=V*t;z=X*t;dis=norm(A*z-u);gam=z'*z;gamw=x'*x;
v=-alf*X*(IA.*z);psi=sqrt(v'*v);
%ur_psi=psi.*(1+(DDD)^2./sqrt(alf));%
ww=U'*u;www=(IA.^3).*ww;ur_psi=sqrt(alf^3*www'*ww);



