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
  D       = Params.fft_data;
  L       = Params.reg_operator;
  W       = Params.weight;
  nx      = Params.nx;
  ny      = Params.ny;
  
%  Compute J(f).  

  Fresid_vec = t_hat.*fft2(f) - D;
  aLf = alpha*(L*f(:));
  WFr = W .* Fresid_vec;
  %Params.Wresid = WFr;
  J = .5 * (Fresid_vec(:)'*WFr(:) + f(:)'*aLf);

%  Compute grad J(f).
  
  if nargout == 3
    %g = feval(Tmult,Wr,conj(t_hat)) + reshape(aLf,nx,ny);
    g = real(ifft2(conj(t_hat).*WFr)) + reshape(aLf,nx,ny);
    TOTAL_GRAD_EVALS = TOTAL_GRAD_EVALS + 1;
  end

  [J_prime,dummy,g_prime] = feval('wls_fun',f,Params);
  fprintf('J-J_prime=%6.3e |g-g_prime|=%6.3e\n',J-J_prime,norm(g(:)-g_prime(:)))
