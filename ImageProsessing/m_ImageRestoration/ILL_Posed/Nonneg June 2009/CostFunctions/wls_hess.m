  function [Hx] = wls_hess(Params,x);
  
%  Compute penalized, weighted least squares matrix-vector product
%  H*x, where
%      H = T'*W*T + alpha*L.

  global TOTAL_HESS_EVALS
  TOTAL_HESS_EVALS = TOTAL_HESS_EVALS + 1;

%  Initialize parameters and vectors.

  Tmult = Params.Tmult_fn;
  t_hat = Params.blurring_operator;
  alpha = Params.reg_param;
  L     = Params.reg_operator;
  W     = Params.weight;
  
%  Compute Hessian vector product.
  
  [Nx,Ny] = size(x);
  Tx = feval(Tmult,x,t_hat);
  Hx = feval(Tmult,W.*Tx,conj(t_hat)) + alpha*reshape(L*x(:),Nx,Ny);

