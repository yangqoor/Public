function T=chebyshev(x,n)
y(1,:)=ones(1,length(x));
y(2,:)=x;
if n>1
  for i=3:n+1
    y(i,:)=2*x.*y(i-1,:)-y(i-2,:);
  end
end
T=y(n+1,:);   

for i=1:n+1
 plot(x,y(i,:));
 grid on;
 axis([-3,3,-10,10]);
 hold on;
end
