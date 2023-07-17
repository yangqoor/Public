  function [x_new,phi_alpha,g_alpha,cost_params,ls_flag] = ... 
            linesrch_quad_uncon(x,p,g,q,q_fn,cost_params,opt_params,alpha_init)
 
%  Use backtracking line search to find approximate solution to
%    min_{alpha>0} phi(alpha),
%  where phi(alpha) = q_fn(x + alpha*p) and q_fn is quadratic.
%
%  Initialize parameters and vectors.
  
  Tmult     = cost_params.Tmult_fn;
  gam       = cost_params.reg_param;
  t_hat     = cost_params.blurring_operator;
  L         = cost_params.reg_operator;
  nx        = cost_params.nx;
  ny        = cost_params.ny;
  ls_param1 = opt_params.linesrch_param1;
  ls_param2 = opt_params.linesrch_param2;

  ls_flag = 0;
  phi_0 = q;
  phi_p_0 = g(:)'*p(:);
  alpha = alpha_init;
  x_new = x + alpha*p;
  [phi_alpha,cost_params,g_alpha] = feval(q_fn,x_new,cost_params);
  ls_iter = 0;
  max_iter = 40;
  mu = .1;

%  Line search iteration.
  
  while ls_flag == 0

    ls_iter = ls_iter + 1;
       
   % Check sufficient decrease condition.
    
    if phi_alpha <= phi_0 + mu*g(:)'*(x_new(:) - x(:)) 
      ls_flag = 3;
      return
    end

   % Minimize the quadratic which interpolates phi_0, phi_p_0 and phi_alpha. 
    
    alpha_new = -.5*phi_p_0*(alpha^2/(phi_alpha - alpha*phi_p_0 - phi_0));

   % Determine new alpha.

    alpha = median([ls_param1*alpha,alpha_new,ls_param2*alpha]);
    
   % Evaluate phi(alpha).

    %x_new = max(x + alpha*p,0);
    [phi_alpha,cost_params,g_alpha] = feval(q_fn,x_new,cost_params);

    if ls_iter >= max_iter
      disp('*** Linesearch Failure: Max Line Search Iters Exceeded ***');
      ls_flag = 4;
    end

  end % while ls_flag == 0    

