function y=S_taylor(x,xn,a,b)
if x-floor(x)~=0
    disp('this program can not handle this kind of problem');
else
    y=(-1)^a*step_prod(a-1)*step_prod(b-1)/step_prod(a-1+x)/step_prod(b-1-x);
    k=length(xn);
    for i=1:k
        y=y*(1-x/xn(i));
    end
end
