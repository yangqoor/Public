% ½âÎö·¨
%  f(w)' = 1/(1+e^())  * e^() * (-x0)
function  dw = grad4(w,x)
x = [x 1];
dw = (-1)*(1+exp(- w*x'))^(-2)*exp(- w*x').*(-x);
end