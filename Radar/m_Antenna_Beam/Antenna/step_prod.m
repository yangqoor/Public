function y=step_prod(x)
if x==0
    y=1;
elseif x<0
    disp('this function can not handle this kind of problem');
else
    y=1;
    for i=1:x
        y=y*x;
        x=x-1;
    end
end