function [F]=Smooth_func(z,alf,A,u)
F=alf*(DFF(z(1))+sum(DFF(diff(z))))+norm(A*z-u)/norm(u);

%  Использование градиента не улучшает решения
%GG=zeros(size(z));GG(1)=sign(z(1))-sign(z(2)-z(1));n=length(z);
%GG(2:n-1)=sign(z(2:n-1)-z(1:n-2))-sign(z(3:n)-z(2:n-1));
%GG(n)=sign(z(n)-z(n-1));
%G=(A'*A*z-A'*u)/norm(u)+alf*GG;