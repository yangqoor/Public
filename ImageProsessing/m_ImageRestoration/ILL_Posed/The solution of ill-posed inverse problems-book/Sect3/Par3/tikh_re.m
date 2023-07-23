function [z,dis,gam]=Tikh_re(A,u,alf)
IA=eye(size(A))*alf+A'*A;z=IA\(A'*u);
dis=norm(A*z-u);gam=norm(z);