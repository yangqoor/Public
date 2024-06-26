  function [x_c,iter_hist] = proj_grad(x_c,opt_params,cost_params,out_params);

%  This m-file is an implimentation of the projected gradient algorithm 
%  to minimize a function subject to nonnegativity constraints.
%
%---------------------------------------------------------------------------
%  Get numerical parameters and function names.
%---------------------------------------------------------------------------

  max_iter     = opt_params.max_iter;     %  Max. no. iterations.
  step_tol     = opt_params.step_tol;     %  Step norm stopping tol.
  pgrad_tol    = opt_params.grad_tol;     %  Proj grad norm stopping tol.
  linesearch   = opt_params.linesrch_fn;  %  Line search function.
  cost_fn      = cost_params.cost_fn;     %  Cost & gradient eval function.
  Hess_mult    = cost_params.hess_fn;     %  Hessian times a vector.

%---------------------------------------------------------------------------
%  Initialization.
%---------------------------------------------------------------------------

  x_c = max(x_c,0);               % Put initial guess in feasible set
  Active = (x_c == 0);            % Compute active set
  Active_prev = Active;
  [J_c,cost_params,g_c] = feval(cost_fn,x_c,cost_params); 
  pg_c = g_c.*((1 - Active) + Active.*(g_c < 0));
  pgradnorm = norm(pg_c(:)); 
  
  %  Output and store numerical performance information.

  iter_hist = [];
  [iter_hist] = output_pg(0,0,pgradnorm,J_c,Active,iter_hist,x_c,out_params);
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Outer iteration.                                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  iter = 0;
  outer_flag = 0;

  while outer_flag == 0;

    iter = iter + 1;

    d_c = -g_c.*((1 - Active) + Active.*(g_c < 0));
      
    %  Compute Cauchy step-length parameter. Then perform linesearch.

    Hd = feval(Hess_mult,cost_params,d_c);
    init_step_param = -g_c(:)'*d_c(:) / (d_c(:)'*Hd(:));
    [x_new,J_c,g_c,cost_params,opt_flag] = feval(linesearch,x_c,...
          d_c,g_c,J_c,cost_fn,cost_params,opt_params,init_step_param);
       
    if opt_flag == 4 % Line search failure.
      return
    end    

    Active = (x_new == 0);
    stepnorm = norm(x_new(:)-x_c(:));
    x_c = x_new;
    pg = g_c.*((1 - Active) + Active.*(g_c < 0));
    pgradnorm = norm(pg(:));
      
    %  Output and store numerical performance information.

    [iter_hist] = output_pg(iter,stepnorm,pgradnorm,J_c,Active,...
                                           iter_hist,x_c,out_params);
  
        %  Check stopping criteria for outer iteration.
      
        if iter >= max_iter
          outer_flag = 1;
          fprintf('   *** Max iterations exceeded ***\n');
	  return
        elseif stepnorm < step_tol * norm(x_c(:))
          outer_flag = 2;
          fprintf('   *** Step norm tolerance met ***\n');
	  return
        elseif pgradnorm < pgrad_tol * iter_hist(3,1)
          outer_flag = 3;
          fprintf('   *** Projected gradient norm tolerance met ***\n');
	  return
        end

  end % while outer_flag == 0
