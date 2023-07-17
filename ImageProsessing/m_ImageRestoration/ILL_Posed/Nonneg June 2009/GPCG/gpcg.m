  function [x_c,iter_hist] = gpcg(x_c,opt_params,cost_params,out_params);

%  This m-file is an implimentation of the GPCG algorithm to minimize
%  a quadratic cost function
%    q(x) = 0.5 * x'*H*x + x'*b
%  subject to nonnegativity constraints.
%  For more information on the GPCG algorithm, see Jorge J. More' and
%  Gerardo Toraldo, "On the Solution of Large Quadratic Programming 
%  Problems with Bound Constraints," SIAM Journal on Optimization, 1,
%  1991, pp. 93-113.

%---------------------------------------------------------------------------
%  Get numerical parameters and function names.
%---------------------------------------------------------------------------

  max_iter     = opt_params.max_iter;     %  Max. no. iterations.
  max_gp       = opt_params.max_gp_iter;  %  Max gradient projection iters.
  max_cg       = opt_params.max_cg_iter;  %  Max cg iters.
  cg_tol       = opt_params.cg_tol;       %  CG stopping tolerance.
  gp_tol       = opt_params.gp_tol;       %  GP stopping tolerance.
  step_tol     = opt_params.step_tol;     %  Step norm stopping tol.
  pgrad_tol    = opt_params.grad_tol;     %  Proj grad norm stopping tol.
  linesearch   = opt_params.linesrch_fn;  %  Line search function.
  cost_fn      = cost_params.cost_fn;     %  Cost & gradient eval function.
  Hess_mult    = cost_params.hess_fn;     %  Hessian mult. function.
  precond      = cost_params.precond_fn;  %  Preconditioner.
  if isempty(precond)     %  Set preconditioning flag.
    precond_flag = 0;
  else
    precond_flag = 1;
  end
  
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
  [iter_hist] = output_gpcg(0,0,0,0,...
        pgradnorm,J_c,Active,iter_hist,x_c,out_params);
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Outer iteration.                                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  iter = 0;
  outer_flag = 0;
  gp_flag = 0;

  while outer_flag == 0;

    iter = iter + 1;
    y_c = x_c;
    x_p = x_c;

%---------------------------------------------------------------------------
%  Gradient projection iteration.
%---------------------------------------------------------------------------
  
    gp_iter = 0;
    J_diff_max = 0;
    
    while gp_flag == 0

      gp_iter = gp_iter + 1;
      d_c = -g_c.*((1 - Active) + Active.*(g_c < 0));
      
      %  Compute Cauchy step-length parameter. Then perform linesearch.

      Hd = feval(Hess_mult,cost_params,d_c);
      init_step_param = -g_c(:)'*d_c(:) / (d_c(:)'*Hd(:));
      [y_new,J_new,g_c,cost_params,opt_flag] = feval(linesearch,y_c,...
          d_c,g_c,J_c,cost_fn,cost_params,opt_params,init_step_param);
       
      if opt_flag == 4 % Line search failure.
        return
      end    

      %  Update information and check stopping criteria.

      Active_new = (y_new == 0);
      same_active = min( Active(:) == Active_new(:) );
      J_diff = J_c - J_new;
      J_diff_max = max(J_diff,J_diff_max);
      
      Active = Active_new;
      y_c = y_new;
      J_c = J_new;
      
      if J_diff < gp_tol*J_diff_max | same_active | gp_iter==max_gp
	gp_flag = 1;
      end
      
    end % while gp_flag == 0

%---------------------------------------------------------------------------
%  Subspace Minimization
%  Use CG to approximately compute an unconstrained minimizer of
%    q(delx) = 0.5*delx'*H*delx + delx'*g
%  where H = projected Hessian, g = projected gradient.
%---------------------------------------------------------------------------
  
    %  Initialization.
  
    x_old = y_c; g_old = g_c; 
    J_old = J_c; Active_old = Active;
    J = J_c;
    delx = zeros(size(g_c));
    resid = -(1-Active) .* g_c;

    %  Set up preconditioner.

    if precond_flag  
      [dummy,cost_params] = feval(precond,resid,Active,cost_params); 
    end

    %  CG iterations.

    J_diff_max = 0;
    cgiter = 0;
    cgiter0 = 0;
    cg_flag = 0;

    while cg_flag == 0

      cgiter = cgiter + 1;
      if precond_flag  % Preconditioning step
        d_c = feval(precond,resid,Active,cost_params);  
      else 
        d_c = resid;
      end
      rd = resid(:)'*d_c(:);
   
      %  Compute conjugate direction p_c.
  
      if cgiter == 1,
        p_c = d_c; 
      else
        betak = rd / rdlast;
        p_c = d_c + betak * p_c;
      end

      %  Form product Hessian*p_c.
    
      Hp = feval(Hess_mult,cost_params,p_c);
      Hp = (1-Active).*Hp;

      %  Update delx and residual.
    
      alphak = rd / (p_c(:)'*Hp(:));
      delx = delx + alphak*p_c;
      resid = resid - alphak*Hp;
      rdlast = rd;
      
      %  J := J(x_old + delx);
      
      J_diff = alphak*(p_c(:)'*(alphak/2 * Hp(:) - resid(:)));
      J = J - J_diff;

      %  Check for sufficient decrease in quadratic or max iter exceeded.
    
      J_diff_max = max(J_diff,J_diff_max);
      if J_diff <= cg_tol*J_diff_max | cgiter == max_cg

        init_step_param = 1;
        [x_c,J_c,g_c,cost_params,opt_flag] = feval(linesearch,x_old,delx,...
              g_old,J_old,cost_fn,cost_params,opt_params,init_step_param);

        if opt_flag == 4  % Line search failure.
          return
        end

        stepnorm = norm(x_c(:)-x_p(:));
        Active = (x_c == 0);
        pg = g_c.*((1 - Active) + Active.*(g_c < 0));
        pgradnorm = norm(pg(:));
      
        %  Output and store numerical performance information.

        [iter_hist] = output_gpcg(iter,gp_iter,cgiter-cgiter0,stepnorm,...
          pgradnorm,J_c,Active,iter_hist,x_c,out_params);
  
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
      
        %  Check CG stopping criteria.
	
        Binding = Active .* (g_c >= 0);     %  Binding set.
        same_active = min( Active(:) == Active_old(:) );
        same_AB = min(Active(:) == Binding(:));
      
        if ~same_AB         %  Active ~= Binding
	
          cg_flag = 1;      %  Stop CG iterations.
          gp_flag = 0;      %  Resume GP iterations.
	
        elseif ~same_active %  Active = Binding while Active ~= Active_old.
          y_c = x_c;
	  gp_flag = 1;      %  Skip GP iterations.
	  gp_iter = 0;
	  cg_flag = 1;      %  Restart CG iterations.

	else                %  Active = Binding = Active_old. Continue CG.
          x_p = x_c;
          gp_iter = 0;
	      J_diff_max = 0;
          cgiter0 = cgiter;
        end

      end % if J_diff ...
    end % CG iteration
  end % while outer_flag == 0
