clear
for (n=3:1:15)
%���ɾ���
%�������Ľ���
%n=input('input n='); 	          
%Hilbert
for i=1:n
    for j=1:n
        a(i,j)=1/(i+j-1);
    end
end;
%����n��b
bc=ones(n,1);
b=a*bc;
%���n��Hilbert����
%%��˹��
%��ȥ
d=[a b];
%disp('--------------------------------------------')
%disp('�������');disp(d)
for k=1:(n-1)  
  for i1=(k+1):n  
    C=d(i1,k)/d(k,k);  
    for j0=(k+1):(n+1)
        d(i1,j0)=d(i1,j0)-C*d(k,j0);
    end
  end
end
%�ش�
x=zeros(n,1);
x(n,1)=d(n,n+1)/d(n,n);
for k1=(n-1):-1:1
    temp=d(k1,n+1);
    for j1=(k1+1):n
        temp=temp-d(k1,j1)*x(j1);
        x(k1,1)=temp/d(k1,k1);
    end
end
%disp('�� :');disp(x)
for i5=1:n
    if x(i5)>1.1||x(i5)<0.9
        disp('��n���ڵ���');disp(n);disp('������10%')
        return;
    end
end
end