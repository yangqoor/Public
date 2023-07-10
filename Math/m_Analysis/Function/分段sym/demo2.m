syms x y 
a=x+y;

% if x>0
%    b=1;
% else
%     b=2;
% end
% ==>
% b=floor(heaviside(x)) - 2*abs(2*heaviside(x) - 1) + 2*floor(-heaviside(x)) + 4;
b=piecewiseSym(x,0,[2,1],2);

eqns = [a + b*x == 1, a - b == 2];
S=solve(eqns,[x y]) 

% 以下是不成功的方法
%% ========================================================================
% % 原始问题
% syms x y 
% a=x+y;
% if x>0
%    b=1;
% else
%     b=2;
% end
% eqns = [a + b*x == 1, a - b == 2];
% S=solve(eqns,[x y]);
% -------------------------------------------------------------------------
% % 报错
% 无法从 sym 转换为 logical。
% 
% 出错 demo2 (第 3 行)
% if x>0


% =========================================================================
% % 逻辑法
% syms x y 
% a=x+y;
% b=1.*(x>0)+2.*(x<=0);
% eqns = [a + b*x == 1, a - b == 2];
% S=solve(eqns,[x y]);
% -------------------------------------------------------------------------
% % 报错
% 错误使用 mupadengine/feval_internal
% System contains an equation of an unknown type.
% 
% 出错 sym/solve (第 293 行)
% sol = eng.feval_internal('solve', eqns, vars, solveOptions);
% 
% 出错 demo3 (第 5 行)
% S=solve(eqns,[x y]);
