  function [Hp] = leastsquareslhd_hess(Params,x,p);
  
%  Compute penalized Poisson log likelihood Hessian matrix-vector product
%  H*x, where
%      H = T'*T + alpha*L.

  global TOTAL_HESS_EVALS
  TOTAL_HESS_EVALS = TOTAL_HESS_EVALS + 1;

%  Initialize parameters and vectors.

  Tmult = Params.Tmult_fn;
  t_hat = Params.blurring_operator;
  alpha = Params.reg_param;
  L     = Params.reg_operator;
  d     = Params.data;
  reg   = Params.reg_choice;
  Wmat  = Params.WeightMat_large;
  
%  Compute Hessian-vector product.
  
  [Nx,Ny] = size(p);
  Tmultp = feval(Tmult,p,t_hat);
  WmatTmultp = Wmat*Tmultp(:);
 
  TtTp = feval(Tmult,reshape(WmatTmultp,Nx,Ny),conj(t_hat));
 
  Hp = TtTp + alpha*reshape(L*p(:),Nx,Ny);
