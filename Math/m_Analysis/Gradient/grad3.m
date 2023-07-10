% 技巧形式的反向传播
% 利用sigmoid 函数的技巧：  sigma(x)' = (1-sigma(x))*sigma(x)
function  dw = grad3(w,x)
% forward
dot = w(1)*x(1) + w(2)*x(2) + w(3);
f = 1.0/(1+exp(-dot));
% backward
ddot = (1-f)*f;
dx = [w(1)*ddot,w(2)*ddot]; % 不输出
dw = [x(1)*ddot,x(2)*ddot,1.0*ddot];
end