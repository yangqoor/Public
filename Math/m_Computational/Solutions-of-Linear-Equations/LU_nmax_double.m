clear
clc
for n=3:1:15
%生成矩阵
%输入矩阵的阶数
%n=input('input n='); 	          
%Hilbert
for i1=1:n
    for j1=1:n
        A(i1,j1)=1/(i1+j1-1);
    end
end;
%生成n阶b
bc=ones(n,1);
b=A*bc;
%LU分解法
L=eye(n);
U=zeros(n,n);
%计算U的第一行，L的第一列
for i=1:n
    U(1,i)=A(1,i);
    L(i,1)=A(i,1)/U(1,1);
end
%计算U的第r行，L的第r列
for i=2:n
    for j=i:n
        for k=1:i-1
            M(k)=L(i,k)*U(k,j);
        end
        U(i,j)=A(i,j)-sum(M);
    end
    for j=i+1:n
        for k=1:i-1
            M(k)=L(j,k)*U(k,i);
        end
        L(j,i)=(A(j,i)-sum(M))/U(i,i);
    end
end
%设Ly=d由于L是下三角矩阵,所以可求y(i)
y(1,1)=b(1);
for i=2:n    
    for j=1:i-1
        b(i)=b(i)-L(i,j)*y(j,1);
    end
    y(i,1)=b(i);
end
%设Ux=y,由于U是上三角矩阵，所以可求x(i)
x(n,1)=y(n,1)/U(n,n);
for i=(n-1):-1:1
    for j=n:-1:i+1
        y(i,1)=y(i,1)-U(i,j)*x(j,1);
    end
    x(i,1)=y(i,1)/U(i,i);
end
%disp(x)
for i5=1:n
    if x(i5,1)>1.1||x(i5,1)<0.9
        disp('当n大于等于');disp(n);disp('误差大于10%')
        return;
    end
end
clear M;
end