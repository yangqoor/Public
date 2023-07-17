function [iter_hist] = output_gp(iter,cg_iter,stepnorm,pgradnorm,J,...
                                           Active,iter_hist,x,params)

%
%  Output and store numerical performance information.
%
%  Column k of iter_hist contains the following information:
%    iter_hist(1,k) = Outer iteration count
%    iter_hist(2,k) = cost function value
%    iter_hist(3,k) = projected gradient norm
%    iter_hist(4,k) = step norm
%    iter_hist(5,k) = relative size of active set
%    iter_hist(6,k) = total cost function evals 
%    iter_hist(7,k) = total hessian evaluations
%    iter_hist(8,k) = relative error
%    iter_hist(9,k) = relative error

  global TOTAL_COST_EVALS TOTAL_HESS_EVALS TOTAL_FFTS
  x_true = params.object;
  rel_error = norm(x(:)-x_true(:))/norm(x_true(:));
  n_active = sum(Active(:));
  ndim = length(Active(:));

  iter_hist = [iter_hist [iter; J; pgradnorm; stepnorm; n_active/ndim; ...
                TOTAL_COST_EVALS; TOTAL_HESS_EVALS; rel_error;TOTAL_FFTS]];

  fprintf('It=%d J=%6.3e |s|=%6.3e |pg|=%6.3e cg_iters=%d #Active=%d\n',iter, J, stepnorm, pgradnorm, cg_iter, n_active); 
  
