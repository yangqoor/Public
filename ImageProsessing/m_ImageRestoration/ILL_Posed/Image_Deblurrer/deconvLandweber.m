function [ x1 ] = deconvLandweber(y,H,iter)
%适用于扁矩阵情况
H=H(:);
L=length(H);
[M,N]=size(y);
if M==1||N==1
    y=y(:);
    [M,N]=size(y);
end
K=M+L-1; %方位向点数，考虑截断影响
HH=flipud(H);%注意要将H翻转一下
A=convmtx(HH.',M);%考虑截断影响
%%%%%%%%%%%%%%%%%%%%%%%%
alfa=1/sum(diag(A*A'));
k=1;
x=zeros(K,N);
while k<iter
    k
    x1=x;
    x=x+alfa*A'*(y-A*x);
    if norm(y-A*x)<0.3264
        break;
    end
    k=k+1;
end
% x=landweber(A,y,10000,zeros(K,1));
x1=x(round(L/2):round(L/2)+M-1,:);