function normXtX = normXtXconv(x,L,ceilL)

%%% compute the norm of XtX where
%%% X = @(x) Hconv(h,x,L)

x = [x(ceilL:end);x(1:ceilL-1)];
normXtX = toeplitz(x,[x(1),x(end:-1:end-L+2)']);
%normXtX = normXtX'*normXtX;
normXtX = norm(normXtX'*normXtX);


