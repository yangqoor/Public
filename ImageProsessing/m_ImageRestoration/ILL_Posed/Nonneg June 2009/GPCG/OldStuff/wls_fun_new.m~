  function [J,Params,g] = wls_fun(f,Params)
  
%  Evaluate penalized, weighted least squares cost functional
%      J(f) = .5*[(T*f-d)'*W*(T*f-d) + alpha*f'*L*f]
%  and the gradient  
%      g(f) = T'*W*(T*f-d) + alpha*L*f.
%
%  Declare global variables and initialize parameters and vectors.

  global TOTAL_COST_EVALS TOTAL_GRAD_EVALS
  TOTAL_COST_EVALS = TOTAL_COST_EVALS + 1;

  Tmult   = Params.Tmult_fn;
  alpha   = Params.reg_param;
  t_hat   = Params.blurring_operator;
  d       = Params.data;
  L       = Params.reg_operator;
  W       = Params.weight;
  nx      = Params.nx;
  ny      = Params.ny;
  
%  Compute J(f).  

  resid_vec = feval(Tmult,f,t_hat) - d;
  aLf = alpha*(L*f(:));
  Wr = W .* resid_vec;
  Params.Wresid = Wr;
  J = .5 * (resid_vec(:)'*Wr(:) + f(:)'*aLf);

%  Compute grad J(f).
  
  if nargout == 3
    g = feval(Tmult,Wr,conj(t_hat)) + reshape(aLf,nx,ny);
    TOTAL_GRAD_EVALS = TOTAL_GRAD_EVALS + 1;
  end

