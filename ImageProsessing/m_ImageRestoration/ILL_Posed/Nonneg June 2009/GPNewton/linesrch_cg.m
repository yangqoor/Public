  function [x_new,phi_alpha,phi_p_alpha,cost_params,ls_iter] = ... 
            linesrch_cg(x,p,g,q,q_fn,cost_params,opt_params,alpha_init)
 
%  Use quadratic backtracking line search to find approximate solution to
%    min_{alpha>0} phi(alpha),
%  where phi(alpha) = cost_fn(x + alpha*p).

  %  Initialize parameters and vectors.
  
  ls_param1 = opt_params.linesrch_param1;
  ls_param2 = opt_params.linesrch_param2;
  phi_0 = q;
  phi_p_0 = g(:)'*p(:);
  alpha = alpha_init;

  x_new = max(x + alpha*p,0);
  [phi_alpha,cost_params,phi_p_alpha] = feval(q_fn,x_new,cost_params);

  ls_flag = 0;
  ls_iter = 0;
  max_iter = 40;

%  Line search iteration.
  
  while ls_flag == 0

    ls_iter = ls_iter + 1;
       
   % Check sufficient decrease condition.
    
    if phi_alpha <= phi_0
      return
    end

   % Minimize the quadratic which interpolates phi_0, phi_p_0 and phi_alpha. 
   % Compute new alpha
   
    denom = phi_alpha - alpha*phi_p_0 - phi_0;
    if denom > 0
      alpha_new = -.5*phi_p_0*(alpha^2/denom);
      alpha = median([ls_param1*alpha,alpha_new,ls_param2*alpha]);
    else
      fprintf('*** Nonpositive denom in linesrch_cg.');
      keyboard
    end

   % Evaluate phi(alpha).

    x_new = max(x + alpha*p,0);
    [phi_alpha,cost_params,phi_p_alpha] = feval(q_fn,x_new,cost_params);

    if ls_iter >= max_iter
      disp('*** Linesearch Error CG: Max Line Search Iters Exceeded ***');
      x_new = x;
      phi_alpha = q;
      phi_p_alpha = g;
    end

  end % while ls_flag == 0    






