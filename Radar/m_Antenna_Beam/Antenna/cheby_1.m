function T=cheby_1(n)
syms x;
y(1)=sym('1');
y(2)=x;
if n>1
  for i=3:n+1
    y(i)=simple(2*x*y(i-1)-y(i-2));
  end
end
T=y(n+1);