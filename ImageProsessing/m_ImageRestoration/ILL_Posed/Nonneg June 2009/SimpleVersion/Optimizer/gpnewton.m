  function [x_c,iter_hist] = gpnewton(x_c,opt_params,cost_params,out_params);

%  This m-file is a modification of the GPCG algorithm to minimize
%  a convex cost functional subject to nonnegativity constraints.

%---------------------------------------------------------------------------
%  Get numerical parameters and function names.
%---------------------------------------------------------------------------

  max_iter      = opt_params.max_iter;     %  Max. no. iterations.
  max_gp        = opt_params.max_gp_iter;  %  Max gradient projection iters.
  max_cg        = opt_params.max_cg_iter;  %  Max cg iters.
  cg_tol        = opt_params.cg_tol;       %  CG stopping tolerance.
  gp_tol        = opt_params.gp_tol;       %  GP stopping tolerance.
  step_tol      = opt_params.step_tol;     %  Step norm stopping tol.
  rel_pgrad_tol = opt_params.grad_tol;     %  Rel. proj grad norm stopping tol.
  linesrch_gp   = opt_params.linesrch_gp;  %  Grad. projection line search.
  linesrch_cg   = opt_params.linesrch_cg;  %  CG linesearch.
  cost_fn       = cost_params.cost_fn;     %  Cost & gradient eval function.
  Hess_mult     = cost_params.hess_fn;     %  Hessian mult. function.
  precond       = cost_params.precond_fn;  %  Preconditioner.
  if isempty(precond)                      %  Set preconditioning flag.
    precond_flag = 0;
  else
    precond_flag = 1;
    start_prec   = cost_params.start_prec;%  Iteration at which to start preconditioning.
  end
  
%---------------------------------------------------------------------------
%  Initialization.
%---------------------------------------------------------------------------

  x_c = max(x_c,0);               % Put initial guess in feasible set
  Active = (x_c == 0);            % Compute active set
  [J_c,cost_params,g_c] = feval(cost_fn,x_c,cost_params);
  pg_c = g_c.*((1 - Active) + Active.*(g_c < 0));
  pgradnorm0 = norm(pg_c(:));
  pgrad_tol = pgradnorm0 * rel_pgrad_tol;  % Compute absolute stopping tolerance
  iter_hist = [];

  %  Output and store numerical performance information.

  [iter_hist] = output_gpnewton(0,0,0,0,...
        pgradnorm0,J_c,Active,iter_hist,x_c,out_params);
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Outer iteration.                                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  iter = 0;
  outer_flag = 0;

  while outer_flag == 0;

    iter = iter + 1;
    x_outer = x_c;

%---------------------------------------------------------------------------
%  Gradient projection iteration.
%---------------------------------------------------------------------------
  
    gp_flag = 0;
    gp_iter = 0;
    J_diff_max = 0;
    
    while gp_flag == 0

      gp_iter = gp_iter + 1;
      d_c = -g_c.*((1 - Active) + Active.*(g_c < 0));
      
      %  Compute Cauchy step-length parameter. Then perform linesearch.

      Hd = feval(Hess_mult,cost_params,x_c,d_c);
      init_step_param = -g_c(:)'*d_c(:) / (d_c(:)'*Hd(:));
      [x_new,J_new,g_c,cost_params,ls_iter] = feval(linesrch_gp,x_c,d_c,...
          g_c,J_c,cost_fn,cost_params,opt_params,init_step_param);

      %  Update information and check stopping criteria.

      Active_new = (x_new == 0);
      same_active = min( Active(:) == Active_new(:) );
      J_diff = J_c - J_new;
      J_diff_max = max(J_diff,J_diff_max);
      
      Active = Active_new;
      x_c = x_new;
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
  
    q = J_c;
    delx = zeros(size(g_c));
    resid = -(1-Active) .* g_c;
    
    %  Set up preconditioner.

    if precond_flag  & iter >= start_prec
      [dummy,cost_params] = feval(precond,resid,Active,cost_params); 
    end

    %  CG iterations.

    q_diff_max = 0;
    cgiter = 0;
    cg_flag = 0;

    while cg_flag == 0

      cgiter = cgiter + 1;
      if precond_flag & iter >= start_prec
        d_c = feval(precond,resid,Active,cost_params);  % Preconditioning step
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

      %  Compute product of reduced Hessian and p_c.
    
      Hp = feval(Hess_mult,cost_params,x_c,p_c);
      Hp = (1-Active).*Hp;

      %  Update delx and residual.
    
      alphak = rd / (p_c(:)'*Hp(:));
      delx = delx + alphak*p_c;
      resid = resid - alphak*Hp;
      rdlast = rd;
      
      %  q := q(x_old + delx);
      
      q_diff = alphak*(p_c(:)'*(alphak/2 * Hp(:) - resid(:)));
      q = q - q_diff;

      %  Check for sufficient decrease in quadratic or max iter exceeded.
    
      q_diff_max = max(q_diff,q_diff_max);
      if q_diff <= cg_tol*q_diff_max | cgiter == max_cg
        cg_flag = 1;
      end 

    end % CG iteration

%---------------------------------------------------------------------------
%  Perform line search in delx direction.
%---------------------------------------------------------------------------

    init_step_param = 1;
    [x_c,J_c,g_c,cost_params,ls_iter] = feval(linesrch_cg,x_c,delx,...
        g_c,J_c,cost_fn,cost_params,opt_params,init_step_param);

%---------------------------------------------------------------------------
%  Output/store information. Check stopping criteria.
%---------------------------------------------------------------------------
  
    stepnorm = norm(x_c(:)-x_outer(:));
    Active = (x_c == 0);
    pg = g_c.*((1 - Active) + Active.*(g_c < 0));
    pgradnorm = norm(pg(:));
      
    [iter_hist] = output_gpnewton(iter,gp_iter,cgiter,stepnorm,...
          pgradnorm,J_c,Active,iter_hist,x_c,out_params);
  
    if iter >= max_iter
      outer_flag = 1;
      fprintf('   *** Max iterations exceeded %d ***\n',max_iter);
      return
    elseif stepnorm < step_tol * norm(x_c(:))
      outer_flag = 2;
      fprintf('   *** Step norm tolerance met %2.3e ***\n',step_tol);
      return
    elseif pgradnorm < pgrad_tol
      outer_flag = 3;
      fprintf('   *** Projected gradient norm tolerance met: %2.3e ***\n',pgrad_tol);
      return
    end
     
  end % while outer_flag == 0
