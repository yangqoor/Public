% 一般形式的反向传播
function  [dw0,dw1,dw2] = grad1(w0,w1,w2,x0,x1)

% forward
p0 = -1*(w0*x0+w1*x1+w2);
p1 = exp(p0);
p2 = 1+p1;
p3 = 1/p2;
% backward
dp2 = (-1)*(p2^(-2));
dp1 = 1*dp2;
dp0 = dp1*exp(p0);

dw0 = dp0*(-x0);
dw1 = dp0*(-x1);
dw2 = dp0 *(-1);
end
