function c=condh(n)
% Hilbert�����2-������

for i=1:n,
    c(i)=cond(H(i),2);
end;

plot([1:n],c);