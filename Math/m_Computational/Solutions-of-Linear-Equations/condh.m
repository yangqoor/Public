function c=condh(n)
% Hilbert矩阵的2-条件数

for i=1:n,
    c(i)=cond(H(i),2);
end;

plot([1:n],c);