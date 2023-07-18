clear
clc
for (n=3:1:15)
%生成矩阵
%输入矩阵的阶数
%n=input('input n='); 	          
%Hilbert
for i=1:n
    for j=1:n
        A(i,j)=1/(i+j-1);
    end
end;
%生成n阶b
bc=ones(n,1);
r=A*bc;
%化为上三角矩阵
s=0;
%-----------------------------------------------------------------
%选非0主元
for j=1:n-1
    for k=1:n-1
      [piv,t] = max(abs(A(k:n,k))); %找列主元所在子矩阵的行r
       t = t + k - 1; % 列主元所在大矩阵的行
      if t>k
       temp1=A(k,:); temp2=r(k);
       A(k,:)=A(t,:); r(k)=r(t);
       A(t,:)=temp1; r(t)=temp2;
      end
    if A(k,k)==0
        error('对角元出现0');
    end
end
%--------------------------------------------------------------
for i=1+s:n-1
        L=A(i+1,j)/A(j,j);
        A(i+1,:)=A(i+1,:)-L*A(j,:);
        r(i+1)=r(i+1)-L*r(j);
end
    s=s+1;
end
%-----------------------------------------------------------------
%回代
x(n)=r(n)/A(n,n);
for i=n-1:-1:1
    sum=0;
    for j=i+1:n
        sum=sum+A(i,j)*x(j);
    end
    x(i)=(1/A(i,i))*(r(i)-sum);
end
%------------------------------
%disp('----------------------------------------------------------')
%disp('输出 [B][x]=[b]')
%disp('上三角行列式 [B] =');disp(A)
%disp('相应的列矩阵 [b] =');disp(r)
%disp('解 :');disp(x')
for i5=1:n
    if x(i5)>1.1||x(i5)<0.9
        disp('当n大于等于');disp(n);disp('误差大于10%')
        return;
    end
end
end