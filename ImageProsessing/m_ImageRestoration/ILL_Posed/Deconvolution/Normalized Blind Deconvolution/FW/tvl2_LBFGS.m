function [u, energy] = tvl2_LBFGS(g, h, lambda, u0,x_iter)
addpath('Solver/L-BFGS/Matlab')

% reconstruction
if nargin<4
    u = convn(g,h,'full');
else
    u = u0;
end

[MI, NI, CC] = size(u);

% here are two equivalent ways to make the gradient. grad2 is sometimes faster
fcn     = @(x) 0.5*sum(sum(sum((convn(reshape(x, MI, NI, CC),h,'valid') - g).^2)))  + lambda*getTVEnergy(reshape(x, MI, NI, CC));
grad    = @(x) reshape(convn(convn(reshape(x, MI, NI, CC),h,'valid') - g, rot90(h,2), 'full')  - lambda*gradTVcc(reshape(x, MI, NI,CC)), MI*NI*CC,1);
% There are  constraints
low_bound   = zeros(MI*NI*CC,1);
up_bound   = ones(MI*NI*CC,1);
fun     = @(x)fminunc_wrapper( x, fcn, grad); 
opts    = struct( 'factr', 1e7, 'pgtol', 1e-6, 'm', 10);
opts.printEvery     = 500;
opts.x0 = u(:);
opts.maxIts = x_iter;
opts.k = h;
opts.g = g;
opts.lambda = lambda;
[x, energy, info] = lbfgsb( fun , low_bound, up_bound, opts );
u = reshape(x, MI, NI,CC);
