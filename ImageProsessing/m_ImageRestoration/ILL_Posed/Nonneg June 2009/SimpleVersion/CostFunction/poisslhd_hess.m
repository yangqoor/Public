  function [Hp] = poisslhd_hess(Params,x,p);
  
%  Compute penalized Poisson log likelihood Hessian matrix-vector product
%  H*x, where
%      H = A'*W*A + alpha*L.
%  Here W = diag( (d+sig^2)./(A*f + c).^2 ), where d denoted data and
%  c = bkgrnd + sig^2.

  global TOTAL_HESS_EVALS
  TOTAL_HESS_EVALS = TOTAL_HESS_EVALS + 1;

%  Initialize parameters and vectors.

  Amult   = Params.Amult;
  ctAmult = Params.ctAmult;
  Aparams = Params.Aparams;
  L       = Params.reg_matrix;
  d       = Params.data;
  sig     = Params.gaussian_stdev;
  Afpc    = Params.Afpc;
  
%  Compute Hessian-vector product.
  
  [Nx,Ny] = size(p);
  W = (d + sig^2) ./ Afpc.^2;
  Ap = feval(Amult,p,Aparams);
  Hp = feval(ctAmult,W.*Ap,Aparams) + reshape(L*p(:),Nx,Ny);
