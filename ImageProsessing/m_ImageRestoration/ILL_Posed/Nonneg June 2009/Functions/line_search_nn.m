  function [x,Jnew,gnew,Lnew,termcode,Jcalls,lambda] = ...
                         line_search_nn(x,s,J,g,cost_fn,cost_params,ls_params)
		     
%
%  Minimize
%       y(lambda) = J(x + lambda*s), x+lambda*s >= 0
%  using a quadratic backtracking line search. J(x) is the cost 
%  functional, g = grad J(x), and s is the search direction.

  GAconst = 1e-2; %ls_params.GA_const;     %  Armejo constant.
  
  lambda  = 1;
  Jcalls = 0;   
  J0 = J;
  Jprime0 = g'*s;
  termcode = -1;
  if Jprime0 >= 0,
    disp(' Direction s is not a descent direction.');
    termcode = 1;
  end  
  
  maxiter = 20;  %  Max. no. line search iterations.
  while termcode < 0,
    Jcalls = Jcalls + 1;
    xnew = max(x + lambda*s,0);
    [Jnew,gnew,Lnew] = feval(cost_fn,xnew,cost_params);  
    
    %%% Check Armejio condition for sufficient decrease in J.
    
    if Jnew - J0 <= GAconst * Jprime0 * lambda,
      x = xnew;
      termcode = 0;
    else
      lambda = lambda/2;
    end
    if Jcalls >= maxiter,
      termcode = 2;
      disp(' Max. no. iterations exceeded in line srch.')
      gnew = g;
      Jnew = J;
      L = [];
    end
  end
  
    
