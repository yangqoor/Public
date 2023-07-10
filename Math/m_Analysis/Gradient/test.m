clc;
%% 下面向量书写的格式不采用统一规范形式。例如全部采用列向量的形式等。
w = [2,-3,-3];
x = [-1,-2];
% 一般形式的反向传播
[dw0,dw1,dw2] = grad1(w(1),w(2),w(3),x(1),x(2));
fprintf('%.8f,%.8f,%.8f \n',dw0,dw1,dw2);
% 数值法
[dw0,dw1,dw2] = grad2(w(1),w(2),w(3),x(1),x(2),1e-5);
fprintf('%.8f,%.8f,%.8f \n',dw0,dw1,dw2);
% 技巧形式的反向传播
dw = grad3(w,x);
fprintf('%.8f,%.8f,%.8f \n',dw(1),dw(2),dw(3));
% 解析法
dw = grad4(w,x);
fprintf('%.8f,%.8f,%.8f \n',dw(1),dw(2),dw(3));
