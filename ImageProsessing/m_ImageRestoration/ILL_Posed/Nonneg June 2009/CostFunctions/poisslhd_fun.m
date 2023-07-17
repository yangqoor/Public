  function [J,Params,g] = poisslhd_fun(f,Params)
  
%  Evaluate penalized Poisson log likelihood cost functional
%      J(f) = sum[(T*f+c) -(d+sig^2).*log(T*f+c)] + alpha/2*f'*L*f.
%  Here d is a realization from a statistical distribution
%      d ~ Poisson(T*f) + Poisson(b) + normal(0,sig^2).
%  The constant c = b + sig^2. 
%  The first term in J(f) is the log likelihood functional for the
%  distributional approximation
%      d_i + sig^2 ~ Poisson([T*f]_i) + Poisson(b) + Poisson(sig^2).
%    The gradient of J is given by 
%      g(f) = T'*[(T*f+b-d)./(T*f+c)] + alpha*L*f.

  %  Declare global variables and initialize parameters and vectors.

  global TOTAL_COST_EVALS TOTAL_GRAD_EVALS
  TOTAL_COST_EVALS = TOTAL_COST_EVALS + 1;

  Tmult   = Params.Tmult_fn;
  alpha   = Params.reg_param;
  t_hat   = Params.blurring_operator;
  d       = Params.data;
  b       = Params.Poiss_bkgrnd;
  sig     = Params.gaussian_stdev;
  nx      = Params.nx;
  ny      = Params.ny;
  reg     = Params.reg_choice;
  
  
  %------------  Compute J(f).  -----------------%
  c = b + sig^2;
  dps = d + sig^2;
  Tfpc = feval(Tmult,f,t_hat) + c;
  Params.Tfpc = Tfpc;
  Jfit = sum(Tfpc(:) - dps(:).*log(Tfpc(:)));
  % Evaluate regularization functional.
  if reg == 0 % Tikhonov
    L = Params.reg_operator;
    aLf = alpha*(L*f(:));
    Jreg = .5*(f(:)'*aLf);
  elseif reg == 1 % Total Variation
    Dx1      = Params.Dx1;
    Dx2      = Params.Dx2;
    Dy1      = Params.Dy1;
    Dy2      = Params.Dy2;
    Delta_xy = Params.Delta_xy;
    beta     = Params.beta;
    Du_sq1   = (Dx1*f(:)).^2 + (Dy1*f(:)).^2;
    Du_sq2   = (Dx2*f(:)).^2 + (Dy2*f(:)).^2;
    Jreg1    = .5 * Delta_xy * sum(psi_fun(Du_sq1,beta));
    Jreg2    = .5 * Delta_xy * sum(psi_fun(Du_sq2,beta));
    Jreg     = alpha * (Jreg1 + Jreg2 ) / 2;
  elseif reg == 2
    L = Params.reg_operator;
    aLf = alpha*(L*f(:));
    Jreg = .5*(f(:)'*aLf);
  end
  J = Jfit + Jreg;
  
  %------------  Compute grad J(f).  -----------------%
  q = (Tfpc - dps) ./ Tfpc;

  gfit = feval(Tmult,q,conj(t_hat));
  
  if reg == 1
    psi_prime1 = psi_prime(Du_sq1, beta);
    psi_prime2 = psi_prime(Du_sq2, beta);
    Dpsi_prime1 = spdiags(psi_prime1, 0, (nx-1)^2,(nx-1)^2);
    Dpsi_prime2 = spdiags(psi_prime2, 0, (nx-1)^2,(nx-1)^2);
    L1 = Dx1' * Dpsi_prime1 * Dx1 + Dy1' * Dpsi_prime1 * Dy1;
    L2 = Dx2' * Dpsi_prime2 * Dx2 + Dy2' * Dpsi_prime2 * Dy2;
    L = (L1 + L2) * Delta_xy / 2;
    Params.reg_operator = L;
    aLf = alpha*(L*f(:));
  end
  g = gfit + reshape(aLf,nx,ny);
  TOTAL_GRAD_EVALS = TOTAL_GRAD_EVALS + 1;
  
