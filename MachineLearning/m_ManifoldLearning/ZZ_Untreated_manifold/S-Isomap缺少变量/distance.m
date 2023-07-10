function result=distance(X,label,alpha)
% This function computes the distance matrix for S-Isomap
%
% X: input data. DxN matrix, D is the dimension, and N is the number of
%    records.
% label: the classe labels of X.
% alpha: the parameter alpha in S-Isomap, usually set to 0.5.

[D,N] = size(X);
fprintf(1,'distance running on %d points in %d dimensions\n',N,D);

X2 = sum(X.^2,1);
distance = sqrt(repmat(X2,N,1)+repmat(X2',1,N)-2*X'*X);

beta=sum(sum(distance))/(N*N);
for i=1:N
    for j=1:N
        if(label(i)==label(j))
            if(sqrt(exp(distance(i,j)^2/beta))-alpha>=sqrt(1-exp(-distance(i,j)^2/beta)))
                distance(i,j)=sqrt(1-exp(-distance(i,j)^2/beta));
            else
                distance(i,j)=(sqrt(exp(distance(i,j)^2/beta))-alpha+sqrt(1-exp(-distance(i,j)^2/beta)))/2;
            end              
        else
           if(sqrt(1-exp(-distance(i,j)^2/beta))<=sqrt(exp(distance(i,j)^2/beta)-alpha))
               distance(i,j)=sqrt(exp(distance(i,j)^2/beta))-alpha; 
           else
               distance(i,j)=(sqrt(exp(distance(i,j)^2/beta))-alpha+sqrt(1-exp(-distance(i,j)^2/beta)))/2;
           end
        end
    end
end
result=distance;
return
