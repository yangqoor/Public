[X,Y]=meshgrid(-1:0.02:1);
theta=-pi/2:pi/100:pi/2;
for m=1:101
    if m==1
        Fx(1)=51;
    else
     Fx(m)=abs(sin(51*pi*sin(theta(m)))./(sin(pi*sin(theta(m)))));
    end
    for n=1:101 
        if n==1
            Fy(1)=51;
        else
        Fy(n)=abs(sin(51*pi*(sin(theta(n))-1))./(sin(pi*(sin(theta(n))-1))));
        end
     F(m,n)=20*log10(Fx(m)*Fy(n)/51.^2);
   end
end
meshc(X,Y,F);
axis([-1 1 -1 1]);