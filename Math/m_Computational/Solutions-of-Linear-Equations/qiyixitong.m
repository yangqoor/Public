function qiyixitong(t)
N=10000000;
delta=0.001;
for i=1:N
    x=(i*pi)^2*dot(((t-t.^3)/6)*(1+delta*rand),2.^(0.5)*sin(i*pi*t))*2.^(0.5)*sin(i*pi*t);
end
x
x0=t;
error=norm(x-x0,2)/norm(x0,2)

    