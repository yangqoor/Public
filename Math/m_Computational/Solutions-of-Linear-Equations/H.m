function h=H(n)
% Hilbert����
for i=1:n,
    for j=i:n,
        h(i,j)=1/(i+j-1);
        h(j,i)=h(i,j);
    end;
end;