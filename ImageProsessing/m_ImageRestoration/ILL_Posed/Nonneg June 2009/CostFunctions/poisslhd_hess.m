  function [Hp] = poisslhd_hess(Params,x,p);
  
%  Compute penalized Poisson log likelihood Hessian matrix-vector product
%  H*x, where
%      H = T'*W*T + alpha*L.
%  Here W = diag( (d+sig^2)./(T*f + c).^2 ), where d denoted data and
%  c = bkgrnd + sig^2.

  global TOTAL_HESS_EVALS
  TOTAL_HESS_EVALS = TOTAL_HESS_EVALS + 1;

%  Initialize parameters and vectors.

  Tmult = Params.Tmult_fn;
  t_hat = Params.blurring_operator;
  alpha = Params.reg_param;
  L     = Params.reg_operator;
  d     = Params.data;
  sig   = Params.gaussian_stdev;
  Tfpc  = Params.Tfpc;
  reg   = Params.reg_choice;
  
%  Compute Hessian-vector product.
  
  [Nx,Ny] = size(p);
  W = (d + sig^2) ./ Tfpc.^2;
  Tp = feval(Tmult,p,t_hat);
  if reg == 1
    L = L;% + getLprime(x,Params);
  end
 
  Hp = feval(Tmult,W.*Tp,conj(t_hat)) + alpha*reshape(L*p(:),Nx,Ny);
  