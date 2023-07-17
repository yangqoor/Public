  function [x_c,iter_hist] = gpnewton(x_c,opt_params,cost_params,out_params);

%  This m-file is an implimentation of the GPCG algorithm to minimize
%  a convex cost functional subject to nonnegativity constraints.

%---------------------------------------------------------------------------
%  Get numerical parameters and function names.
%---------------------------------------------------------------------------

  max_iter      = opt_params.max_iter;     %  Max. no. iterations.
  max_gp_iter   = opt_params.max_gp_iter;  %  Max gradient projection iters.
  max_cg        = opt_params.max_cg_iter;  %  Max cg iters.
  cg_tol        = opt_params.cg_tol;       %  CG stopping tolerance.
  gp_tol        = opt_params.gp_tol;       %  GP stopping tolerance.
  step_tol      = opt_params.step_tol;     %  Step norm stopping tol.
  rel_pgrad_tol = opt_params.grad_tol;     %  Rel. proj grad norm stopping tol.
  cost_fn       = cost_params.cost_fn;     %  Cost & gradient eval function.
  Hess_mult     = cost_params.hess_fn;     %  Hessian mult. function.
  precond       = cost_params.precond_fn;  %  Preconditioner.
  linesrch_gp   = opt_params.linesrch_gp;
  linesrch_cg   = opt_params.linesrch_cg;
  if isempty(precond)     %  Set preconditioning flag.
    precond_flag = 0;
  else
    precond_flag = 1;
  end
  
%---------------------------------------------------------------------------
%  Initialization.
%---------------------------------------------------------------------------

  iter = 0;
  outer_flag = 0;
  gp_flag = 0;
  max_gp = max_gp_iter;
  x_c = max(x_c,0);               % Put initial guess in feasible set
  Active = (x_c == 0);            % Compute active set
  [J_c,Tfpc,g_c] = feval(cost_fn,x_c,cost_params);
  cost_params.Tfpc = Tfpc;
  pg_c = g_c.*((1 - Active) + Active.*(g_c < 0));
  pgradnorm = norm(pg_c(:),'inf');
  pgrad_tol = pgradnorm * rel_pgrad_tol;  % Compute absolute stopping tolerance
  iter_hist = [];
  
  %  Output and store numerical performance information.

  [iter_hist] = output_gpnewton(0,0,0,0,...
        pgradnorm,J_c,Active,iter_hist,x_c,out_params);
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Outer iteration.                                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  while outer_flag == 0;

    iter = iter + 1;

%---------------------------------------------------------------------------
%  Gradient projection iteration.
%---------------------------------------------------------------------------
  
    gp_iter = 0;
    J_diff_max = 0;
    
    while gp_flag == 0
      gp_iter = gp_iter + 1;
      d_c = -g_c;
%%%      d_c = -g_c.*((1 - Active) + Active.*(g_c < 0));
      
      %  Compute Cauchy step-length parameter. Then perform linesearch.

      Hd = feval(Hess_mult,cost_params,d_c);
      init_step_param = -g_c(:)'*d_c(:) / (d_c(:)'*Hd(:));
      [x_new,J_new,g_c,Tfpc,ls_iter] = feval(linesrch_gp,x_c,d_c,g_c,J_c,...
          cost_fn,cost_params,opt_params,init_step_param);
      Active_new = (x_new == 0);
      same_active = min( Active(:) == Active_new(:) );
      J_diff = J_c - J_new;
      J_diff_max = max(J_diff,J_diff_max);
      
      if J_diff<gp_tol*J_diff_max | same_active | gp_iter==max_gp
	gp_flag = 1;
      end

      Active = Active_new;
      x_c = x_new;
      J_c = J_new;

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
    q_diff_max = 0;
    cgiter = 0;
    cg_flag = 0;
    cgiter0 = 0;
    cost_params.Tfpc = Tfpc;
    if precond_flag  %  Set up preconditioner.
      [dummy,cost_params] = feval(precond,resid,Active,cost_params); 
    end

    %  CG iterations.

    while cg_flag == 0

      cgiter = cgiter + 1;
      if precond_flag
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

      %  Form product Hessian*p_c.
    
      Hp = feval(Hess_mult,cost_params,p_c);
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

%%%delx(Active) = -g_c(Active);
    init_step_param = 1;
    [x_new,J_new,g_c,Tfpc,ls_iter] = feval(linesrch_cg,x_c,delx,...
        g_c,J_c,cost_fn,cost_params,opt_params,init_step_param);

    stepnorm = norm(x_new(:)-x_c(:));
    Active_new = (x_new == 0);
    pg = g_c.*((1 - Active) + Active.*(g_c < 0));
    pgradnorm = norm(pg(:),'inf');
      
    %  Output and store numerical performance information.

    [iter_hist] = output_gpnewton(iter,gp_iter,cgiter,stepnorm,...
          pgradnorm,J_new,Active_new,iter_hist,x_new,out_params);
  
    %  Check stopping criteria for outer iteration.
      
    if iter >= max_iter
      outer_flag = 1;
      fprintf('   *** Max iterations exceeded ***\n');
      return
    elseif stepnorm < step_tol * norm(x_c(:))
      outer_flag = 2;
      fprintf('   *** Step norm tolerance met ***\n');
      return
    elseif pgradnorm < pgrad_tol
      outer_flag = 3;
      fprintf('   *** Projected gradient norm tolerance met ***\n');
      return
    end
      
%---------------------------------------------------------------------------
%  Determine max iteration count for next GP iterations. This seems to
%  reduce computational cost when no preconditioning is used.
%---------------------------------------------------------------------------
    
    Binding = Active_new.*(g_c>=0);     %  Binding set.
    same_AB = min(Active_new(:) == Binding(:));
    if ~same_AB       %  Active and binding sets differ.
      max_gp = max_gp_iter;
    else
      max_gp = 1;
    end

    gp_flag = 0;
    x_c = x_new;
    J_c = J_new;
    Active = Active_new;
    
  end % while outer_flag == 0
