function [N,A,u,z,ML,x,t]=model1(numm);

%   Генерация модели
if numm==1;
N=21;NUL=8;
A1=toeplitz([1./(1+([0:N-1].^2))]);
[U,RR,V]=svd(A1);[RR1,J]=sort(diag(RR));RR1(1:NUL)=0;RR2=RR1(J);A=U*diag(RR2)*V';
z=A*A*ones(N,1);x=[1:N];t=x;
ML=10;% Пределы изменения решения (для графика)
u=A*z;
elseif numm==2;
  N=21;NUL=4;
  A1=toeplitz([1./(1+([0:N-1]))]);
[U,RR,V]=svd(A1);[RR1,J]=sort(diag(RR));RR1(1:NUL)=0;RR2=RR1(J);A=U*diag(RR2)*V';
z=A*ones(N,1);x=[1:N];t=x;
ML=6;% Пределы изменения решения (для графика)
u=A*z;
else
end
