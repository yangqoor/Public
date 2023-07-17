  function [x_new,phi_alpha,phi_p_alpha,cost_params,ls_iter] = ... 
         linesrch_gp(x,p,g,J,cost_fn,cost_params,opt_params,alpha_init)

%  Line search to be used with gradient projection algorithm.
		      
%  Initialization.

  ls_param1 = opt_params.linesrch_param1;
  ls_param2 = opt_params.linesrch_param2;
  phi_0 = J;
  phi_p_0 = g(:)'*p(:);
  alpha = alpha_init;

  x_new = max(x + alpha*p,0);
  [phi_alpha,cost_params,phi_p_alpha] = feval(cost_fn,x_new,cost_params);

  mu = .5;        % Sufficient decrease parameter.
  ls_flag = 0;
  ls_iter = 0;
  max_iter = 40;

%  Iteration.
  
  while ls_flag == 0

    ls_iter = ls_iter + 1;
       
    % Check the sufficient decrease condition. (See Bertsekas)

    if phi_alpha < phi_0 - (mu/alpha)*norm(x_new(:) - x(:))^2
      return
    end

    % Minimize the quadratic which interpolates phi_0, phi_p_0 and phi_alpha. 
    % Compute new alpha
   
    denom = phi_alpha - alpha*phi_p_0 - phi_0;
    if denom > 0
      alpha_new = -.5*phi_p_0*(alpha^2/denom);
      alpha = median([ls_param1*alpha,alpha_new,ls_param2*alpha]);
    else
      fprintf('*** Nonpositive denom in linesrch_gp.');
      %keyboard
      alpha = .1*alpha;
    end

   % Evaluate phi(alpha).

    x_new = max(x + alpha*p,0);
    [phi_alpha,cost_params,phi_p_alpha] = feval(cost_fn,x_new,cost_params);  
    if ls_iter >= max_iter
      disp('*** Linesearch Error GP: Max Line Search Iters Exceeded ***');
      x_new = x;
      phi_alpha = J;
      phi_p_alpha = g;
    end

  end % while ls_flag == 0    

