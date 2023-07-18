function Zzqy(t)
N=1000000;
delta=0.1;
alpha=delta*rand;
for i=1:N
    x=1/(alpha*(i*pi)^2+1)*dot((t-t.^3)/6,2.^(0.5)*sin(i*pi*t))*2.^(0.5)*sin(i*pi*t);
end
x
x0=-t;
error=norm(x-x0,2)/norm(x0,2)
