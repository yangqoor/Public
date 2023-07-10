num=0;
[a,b,c,d,e,f]=textread('f.txt','%d %f %f %f %f %s');
temp=f(1);
M=zeros(length(a),6);
attri(1)=1;
for i=1:length(f)
    if(~strcmp(temp,f(i)))
        temp=f(i);
        num=num+1;
        attri(num+1)=i;
    end
    M(i,6)=num;
end
attri(num+2)=length(f)+1;
M(1:length(a),1)=a;
M(1:length(a),2)=b;
M(1:length(a),3)=c;
M(1:length(a),4)=d;
M(1:length(a),5)=e;

%区间矩阵S
for i=1:num+1   
    for k=2:5
        S(i,k-1).min=M(attri(i),k);
        S(i,k-1).max=M(attri(i),k);
        for j=attri(i):(attri(i+1)-1)
            if(M(j,k)<S(i,k-1).min)
                S(i,k-1).min=M(j,k);
            end
            if(M(j,k)>S(i,k-1).max)
                S(i,k-1).max=M(j,k);
            end
        end
    end
end

%均值矩阵P
for i=1:num+1
    for k=2:5
        sum=0;
        for j=attri(i):(attri(i+1)-1)
            sum=sum+M(j,k);
        end
        P(i,k-1)=sum/(attri(i+1)-attri(i));
    end
end
%分割点矩阵T
for i=1:num
    for j=1:4
        T(i,j)=(P(i,j)+P(i+1,j))/2;
    end
end
%离散化数据矩阵Y
W=T;
for i=1:4   %对分割点矩阵每列从小到大排序
    for j=1:num-1
        if(W(j,i)>W(j+1,i))
            temp=W(j,i);
            W(j,i)=W(j+1,i);
            W(j+1,i)=temp;
        end
    end
end
for i=1:length(a)
    for j=1:4
        k=1;
        while( k<=num & M(i,j+1)>W(k,j))
            k=k+1;
        end
        Y(i,j)=k-1;
    end
end
Y(1:end,5)=M(1:end,6);
Y