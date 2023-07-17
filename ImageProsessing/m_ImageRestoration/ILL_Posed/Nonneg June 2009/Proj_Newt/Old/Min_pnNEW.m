%  Min_pn.m
%
%  Use the projected newton algorithm to minimize a 
%  function f subject to a nonnegativity constraint.

%------------------------------------------------------------------------
%  Set up parameters and data to evaluate cost function and its
%  Hessian. Store information in structure array Cost_params. 
%------------------------------------------------------------------------

  alpha = input(' Regularization parameter = ');
  nx = Data.nx;
  ny = Data.ny;
  n = nx*ny;
  
  %  Set up and store regularization operator.
  
  reg_flag = 0; %input(' Enter 0 for Identity; 1 for -Laplacian reg: ');
  if reg_flag == 1  %  Negative Laplacian regularization operator.
    L = laplacian(nx,ny);
  else              %  Identity regularization operator.
    L = speye(nx*ny);
  end

  %  Set up and store components of diagonal weight matrix.
  
  w_flag = 0;%%input(' Enter 1 for weighted ls; enter 0 otherwise: ');
  const = Data.Poiss_bkgrnd + Data.gaussian_stdev^2;
  if w_flag == 1  %  W = 1./([T*f_true]_i + bkgrnd + stdev^2);
    W = 1./(Data.noise_free_data + const);
  else
    W = (1/const) * ones(nx,ny);
  end

  if Data.type == 'circ' & w_flag == 0
    Cost_params.cost_fn           = 'ls_fun_circ';
    Cost_params.hess_fn           = 'ls_hess_circ';
    Cost_params.const             = const;
  else
    Cost_params.cost_fn           = 'poisslhd_funNEW';  
    Cost_params.hess_fn           = 'poisslhd_hess';
  end

  Cost_params.nx                  = nx;
  Cost_params.ny                  = ny;
  Cost_params.data                = Data.noisy_data;
  Cost_params.fft_data            = fft2(Data.noisy_data);
  Cost_params.reg_param           = alpha;
  Cost_params.gaussian_stdev      = Data.gaussian_stdev;
  Cost_params.Poiss_bkgrnd        = Data.Poiss_bkgrnd;
  Cost_params.reg_operator        = L;
  Cost_params.weight              = W;
  if Data.type == 'toep'
    Cost_params.Tmult_fn          = 'bttb_mult_fft';
    Cost_params.blurring_operator = Data.BTTB_kernel_fft;
  else  % type = 'circ'
    Cost_params.Tmult_fn          = 'bccb_mult_fft';
    Cost_params.blurring_operator = Data.BCCB_kernel_fft;
  end
  % Regularization
  Cost_params.reg_choice = input(' Enter 0 for Tikhonov; 1 for TV. ');
  if Cost_params.reg_choice == 1;
    %  Set up discretization of first derivative operators.
    nsq = nx^2;
    Delta_x = 1 / nx;
    Delta_y = Delta_x;
    Delta_xy = 1;%Delta_x*Delta_y;
    D = spdiags([-ones(nx-1,1) ones(nx-1,1)], [0 1], nx-1,nx) / Delta_x;
    I_trunc1 = spdiags(ones(nx-1,1), 0, nx-1,nx);
    I_trunc2 = spdiags(ones(nx-1,1), 1, nx-1,nx);
    Dx1 = kron(D,I_trunc1);
    Dx2 = kron(D,I_trunc2);
    Dy1 = kron(I_trunc1,D);
    Dy2 = kron(I_trunc2,D);
    % Necessaries for cost function evaluation.
    Cost_params.Dx1 = Dx1;
    Cost_params.Dx2 = Dx2;
    Cost_params.Dy1 = Dy1;
    Cost_params.Dy2 = Dy2;
    Cost_params.Delta_xy = Delta_xy;
    Cost_params.beta = 1;
  end
%------------------------------------------------------------------------
%  Build and store preconditioner.
%------------------------------------------------------------------------

  p_flag = input(' Enter 1 for preconditioning; else enter 0: ');
  if p_flag == 0
    Cost_params.precond_fn = [];
  else
    if Data.type == 'toep'
      psf = Data.BTTB_kernel;
      array2mat = 'sparse_bttb';
      T_sparse_fn = 'T_sparse_toep';
    else
      psf = fftshift(Data.BCCB_kernel);
      array2mat = 'sparse_bccb';
      T_sparse_fn = 'T_sparse_circ';
    end
    cutoff_percentage = 10; %%%input(' PSF cutoff percentage = ');
    max_psf = max(psf(:));
    mask_cutoff = cutoff_percentage*max_psf/100;
    mask = (psf >= mask_cutoff); 
    sparse_psf = mask.*psf;
    fprintf('... setting up preconditioner ...\n');
    T_sparse = feval(T_sparse_fn,array2mat,sparse_psf);
    W_mat = spdiags(W(:), 0, n,n);
    M = T_sparse' * W_mat * T_sparse + alpha * L;
    Cost_params.precond_matrix = M;
    Cost_params.precond_fn = 'sparse_wls_precond';
    Cost_params.start_prec = 5;  %  Iteration at which to start preconditioning.
  end

%------------------------------------------------------------------------
%  Set up and store optimization parameters in structure array Opt_params.
%------------------------------------------------------------------------

  Opt_params.max_iter    = input(' Max number of iterations = ');
  Opt_params.max_cg_iter  = input(' Max CG iterations = ');
  Opt_params.cg_tol      = .1;
  Opt_params.step_tol    = 1e-10;  % termination criterion: norm(step)
  Opt_params.grad_tol    = 1e-7;   % termination criterion: rel norm(grad)
  Opt_params.linesrch_param1   = 0.1;  % Update parameters for quadratic 
  Opt_params.linesrch_param2   = 0.5;  %   backtracking line search. 
  Opt_params.linesrch_fn       = 'linesrch_quad'; % GPCG line search function.
  
%------------------------------------------------------------------------
%  Declare and initialize global variables.
%------------------------------------------------------------------------
  
  global TOTAL_COST_EVALS TOTAL_GRAD_EVALS TOTAL_HESS_EVALS TOTAL_FFTS
  global TOTAL_PRECOND_SETUPS TOTAL_PRECOND_EVALS
  TOTAL_COST_EVALS = 0; 
  TOTAL_GRAD_EVALS = 0; 
  TOTAL_HESS_EVALS = 0; 
  TOTAL_FFTS = 0;
  TOTAL_PRECOND_SETUPS = 0;
  TOTAL_PRECOND_EVALS = 0;
  TOTAL_FFT_TIME = 0;
  TOTAL_PRECOND_TIME = 0;
  
%---------------------------------------------------------------------
%  Set initial guess.
%---------------------------------------------------------------------
  
  init_flag = input(' Reset initial guess? (0 = no; 1 = yes): ');
  if init_flag == 1        % Reset initial guess
    f_0 = ones(nx,ny);
  else
    f_0 = f;
  end

%---------------------------------------------------------------------
%  Solve minimization problem.
%---------------------------------------------------------------------
  
  cpu_t0 = cputime;
  [f,histout] = proj_newton(f_0,Opt_params,Cost_params,Data);
  total_cpu_time = cputime - cpu_t0;
    
%---------------------------------------------------------------------
%  Display results.
%---------------------------------------------------------------------
    
  f_wls = reshape(f,nx,ny);
  f_true = Data.object;
    
    figure(5)
      imagesc(f_wls), colorbar
      title('Reconstructed Object')
      
    figure(6)
      imagesc(f_true), colorbar
      title('True Object')

    figure(7)
      subplot(221)
        xx = histout(9,:);
	yy = histout(3,:); 
        semilogy(xx,yy,'o-')
        xlabel('Cumulative FFTs')
        title('Projected Gradient Norm')
      subplot(222)
        xx = histout(9,:);
	yy = histout(2,:); 
        semilogy(xx,yy,'o-')        
        xlabel('Cumulative FFTs')
	title('Cost Function')
      subplot(223)
        xx = histout(9,:);
	yy = histout(4,:); 
        semilogy(xx,yy,'o-')
        xlabel('Cumulative FFTs')
        title('Step Norm')
      subplot(224)
        xx = histout(9,:);
	yy = histout(5,:);
        plot(xx,yy,'o-')
        xlabel('Cumulative FFTs')
	title('Relative Size of Active Set')

    figure(8)
      xx = histout(9,:);
      yy = histout(8,:);
      semilogy(xx,yy,'o-')
      xlabel('Cumulative FFTs')
      title('Relative Solution Error Norm')

    wls_rel_err = norm(f_wls-f_true,'fro')/norm(f_true(:));
    fprintf('Relative soln error             = %f\n',wls_rel_err);
    fprintf('Total cost function evaluations = %d\n',TOTAL_COST_EVALS)
    fprintf('Total grad function evaluations = %d\n',TOTAL_GRAD_EVALS)
    fprintf('Total Hess function evaluations = %d\n',TOTAL_HESS_EVALS)
    fprintf('Total fast fourier transforms   = %d\n',TOTAL_FFTS)
    fprintf('Total preconditioner setups     = %d\n',TOTAL_PRECOND_SETUPS)
    fprintf('Total preconditioner evals      = %d\n',TOTAL_PRECOND_EVALS)
    fprintf('Total CPU time, in seconds      = %d\n',total_cpu_time);
    fprintf('FFT CPU time                    = %d\n',TOTAL_FFT_TIME);
    fprintf('Preconditioning time            = %d\n',TOTAL_PRECOND_TIME);
