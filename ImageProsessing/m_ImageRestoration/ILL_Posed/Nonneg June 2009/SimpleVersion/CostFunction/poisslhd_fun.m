  function [J,Params,g] = poisslhd_fun(f,Params)
  
%  Evaluate penalized Poisson log likelihood cost functional
%      J(f) = sum[(A*f+c) -(d+sig^2).*log(A*f+c)] + alpha/2*f'*L*f.
%  Here d is a realization from a statistical distribution
%      d ~ Poisson(A*f) + Poisson(b) + normal(0,sig^2).
%  Ahe constant c = b + sig^2. 
%  The first term in J(f) is the log likelihood functional for the
%  distributional approximation
%      d_i + sig^2 ~ Poisson([A*f]_i) + Poisson(b) + Poisson(sig^2).
%    The gradient of J is given by 
%      g(f) = A'*[(A*f+b-d)./(A*f+c)] + alpha*L*f.

  %  Declare global variables and initialize parameters and vectors.

  global TOTAL_COST_EVALS TOTAL_GRAD_EVALS
  TOTAL_COST_EVALS = TOTAL_COST_EVALS + 1;

  Amult   = Params.Amult;
  ctAmult = Params.ctAmult;
  L       = Params.reg_matrix;
  Aparams = Params.Aparams;
  d       = Params.data;
  b       = Params.Poiss_bkgrnd;
  sig     = Params.gaussian_stdev;
  nx      = Params.nx;
  ny      = Params.ny;
   
  %------------  Compute J(f).  -----------------%
  c = b + sig^2;
  dps = d + sig^2;
  Afpc = feval(Amult,f,Aparams) + c;
  Params.Afpc = Afpc;
  Jfit = sum(Afpc(:) - dps(:).*log(Afpc(:)));
  Lf = L*f(:);
  Jreg = .5*(f(:)'*Lf);
  J = Jfit + Jreg;
  
  %------------  Compute grad J(f).  -----------------%
  q = (Afpc - dps) ./ Afpc;
  gfit = feval(ctAmult,q,Aparams);
  g = gfit + reshape(Lf,nx,ny);
  TOTAL_GRAD_EVALS = TOTAL_GRAD_EVALS + 1;
  
