  function [x_c,iter_hist] = lagged_diffusivity(x_c,opt_params,...
                                               cost_params,out_params);

%  This m-file is an implimentation of the Projected Newton algorithm to minimize
%  a quadratic cost function
%    q(x) = 0.5 * x'*H*x + x'*b
%  subject to nonnegativity constraints.
%  For more information on see C.T. Kelley,

%---------------------------------------------------------------------------
%  Get numerical parameters and function names.
%---------------------------------------------------------------------------

  max_iter     = opt_params.max_iter;     %  Max. no. iterations.
  max_cg       = opt_params.max_cg_iter;  %  Max cg iters.
  cg_tol       = opt_params.cg_tol;       %  CG stopping tolerance.
  step_tol     = opt_params.step_tol;     %  Step norm stopping tol.
  grad_tol     = opt_params.grad_tol;     %  Proj grad norm stopping tol.
  linesearch   = opt_params.linesrch_fn;  %  Line search function.
  cost_fn      = cost_params.cost_fn;     %  Cost & gradient eval function.
  Hess_mult    = cost_params.hess_fn;     %  Hessian mult. function.
  precond      = cost_params.precond_fn;  %  Preconditioner.
  if isempty(precond)     %  Set preconditioning flag.
    precond_flag = 0;
  else
    precond_flag = 1;
    start_prec   = cost_params.start_prec;%  Iteration at which to start preconditioning.
    Active = zeros(size(x_c));
  end
  
%---------------------------------------------------------------------------
%  Initialization.
%---------------------------------------------------------------------------

  [J_c,cost_params,g_c] = feval(cost_fn,x_c,cost_params); 
  gradnorm = norm(g_c(:)); 
  
  %  Output and store numerical performance information.

  iter_hist = [];
  [iter_hist] = output_ld(0,0,0,gradnorm,J_c,iter_hist,x_c,out_params);
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Outer iteration.                                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  iter = 0;
  outer_flag = 0;
  
  while outer_flag == 0;

    iter = iter + 1;

    J = J_c;
    delx = zeros(size(g_c));
    resid = - g_c;
    tolerance = min(.5,norm(g_c(:)));

    %  Set up preconditioner.
    if precond_flag & iter >= start_prec
      [dummy,cost_params] = feval(precond,resid,Active,cost_params); 
    end

    %  CG iterations.
    cgiter = 0;
    cgiter0 = 0;
    cg_flag = 0;

    while cg_flag == 0

      cgiter = cgiter + 1;
      if precond_flag  & iter >= start_prec % Preconditioning step
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
      Hp = feval(Hess_mult,cost_params,x_c,p_c);
      
      %  Update delx and residual.
      alphak = rd / (p_c(:)'*Hp(:));
      delx = delx + alphak*p_c;
      resid = resid - alphak*Hp;
      rdlast = rd;
      
      if norm(resid(:))<=tolerance | cgiter == max_cg 
        cg_flag = 1;
      end

    end % while cg_flag == 0
     
    x_new = x_c + delx;  
    [x_new,phi_alpha,g_alpha,cost_params,ls_flag] = linesrch_quad_uncon(x_c,...
                                     delx,g_c,J_c,cost_fn,cost_params,opt_params,1);
    stepnorm = norm(x_new(:)-x_c(:));
    x_c = x_new;
    [J_c,cost_params,g_c] = feval(cost_fn,x_c,cost_params); 
    gradnorm = norm(g_c(:));
      
    %  Output and store numerical performance information.

    [iter_hist] = output_ld(iter,cgiter,stepnorm,...
          gradnorm,J_c,iter_hist,x_c,out_params);
  
    %  Check stopping criteria for outer iteration.
      
    if iter >= max_iter
      outer_flag = 1;
      fprintf('   *** Max iterations exceeded ***\n');
      return
    elseif stepnorm < step_tol * norm(x_c(:))
      outer_flag = 2;
      fprintf('   *** Step norm tolerance met ***\n');
      return
    elseif gradnorm < grad_tol * iter_hist(3,1)
      outer_flag = 3;
      fprintf('   *** Projected gradient norm tolerance met ***\n');
      return
    end
      
  end % while outer_flag == 0
