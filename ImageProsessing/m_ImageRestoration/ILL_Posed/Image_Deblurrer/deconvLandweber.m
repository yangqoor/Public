function [ x1 ] = deconvLandweber(y,H,iter)
%�����ڱ�������
H=H(:);
L=length(H);
[M,N]=size(y);
if M==1||N==1
    y=y(:);
    [M,N]=size(y);
end
K=M+L-1; %��λ����������ǽض�Ӱ��
HH=flipud(H);%ע��Ҫ��H��תһ��
A=convmtx(HH.',M);%���ǽض�Ӱ��
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