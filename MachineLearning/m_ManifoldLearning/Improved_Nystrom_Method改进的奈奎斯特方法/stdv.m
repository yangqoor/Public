function b = stdv(data);
[n,dim]=size(data);
dis = zeros(n,1);
m = mean(data);
for i = 1:n;
    dis(i) = norm(m - data(i,:))^2;
end;
b = mean(dis);
