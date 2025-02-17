%  Min_poisson.m
%
%  Minimize penalized Poisson log likelihood functional
%    J(x) = sum(Txps - d.*log(Txps)) + alpha/2*x'*L*x
%  subject to nonnegativity constraints. Here 
%    Txps = T*x + sigma^2,
%  T is the blurring operator, d is the data, alpha is the
%  regularization parameter, L is the regularization matrix, and
%  sigma is a positive parameter.
%------------------------------------------------------------------------
%  Set up parameters and data to evaluate cost function and its
%  Hessian. Store information in structure array Cost_params. 
%------------------------------------------------------------------------

  alpha = input(' Regularization parameter = ');
  nx = Data.nx;
  ny = Data.ny;
  n = nx*ny;
  
  %  Set up and store regularization operator.
  Cost_params.reg_choice = input(' Enter 0 for Tikhonov; 1 for TV; and 2 for Laplacian. ');
  if Cost_params.reg_choice == 2
     Cost_params.reg_operator = laplacian(nx,ny);
  elseif Cost_params.reg_choice == 1  % Negative Laplacian regularization operator.
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
  else              %  Identity regularization operator.
    Cost_params.reg_operator = speye(nx*ny);
  end
    
  Cost_params.nx                = nx;
  Cost_params.ny                = ny;
  Cost_params.cost_fn           = 'leastsquareslhd_fun';
  Cost_params.hess_fn           = 'leastsquareslhd_hess';
  Cost_params.data              = Data.noisy_data;
  Cost_params.reg_param         = alpha;
  Cost_params.gaussian_stdev    = Data.gaussian_stdev;
  Cost_params.Poiss_bkgrnd      = Data.Poiss_bkgrnd;
  if Data.type == 'toep'
    Cost_params.Tmult_fn          = 'bttb_mult_fft';
    Cost_params.blurring_operator = Data.BTTB_kernel_fft;
    Cost_params.tflag             = 0;
  elseif   Data.type == 'circ'
    Cost_params.Tmult_fn          = 'bccb_mult_fft';
    Cost_params.blurring_operator = Data.BCCB_kernel_fft;
   Cost_params.tflag = 0;
  else
       
        Cost_params.Tmult_fn          = 'Amult_PET';
        Aparams = Data.Aparams;
        A = Aparams.A;
    Cost_params.blurring_operator = A;
    
    Cost_params.tflag             = 1;
  end
  
  
  w_flag = input(' Enter 1 for weighted ls; enter 0 otherwise: ');
  const = Data.Poiss_bkgrnd + Data.gaussian_stdev^2;
  if w_flag == 1  %  W = 1./([T*f_true]_i + bkgrnd + stdev^2);
    W = 1./(Data.noise_free_data + const);
  else
    W =ones(nx,ny);% (1/const) * ones(nx,ny);
  end
  Cost_params.WeightMat_large = spdiags(W(:),0,nx*ny,nx*ny);
  
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
    setup_flag = input(' Enter 1 to create sparse PSF and 0 otherwise. ');
    if setup_flag == 1
      fprintf(' ... setting up preconditioner ...\n');
      T_sparse = feval(T_sparse_fn,array2mat,sparse_psf);
    end
    Cost_params.precond_fn = 'sparse_precond_wls';
    Cost_params.sparse_approx = T_sparse;
    Cost_params.start_prec = 5;  %  Iteration at which to start preconditioning.
  end
  
%------------------------------------------------------------------------
%  Set up and store optimization parameters in structure array Opt_params.
%------------------------------------------------------------------------

  Opt_params.max_iter          = 100;  %input(' Max number of iterations = ');
  Opt_params.step_tol          = 1e-10;  % termination criterion: norm(step)
  Opt_params.grad_tol          = 1e-3;  % termination criterion: rel norm(grad)
  Opt_params.max_gp_iter       = 10;  %input(' Max gradient projection iters = ');
  Opt_params.max_cg_iter       = 40;  %input(' Max conjugate gradient iters = ');
  Opt_params.gp_tol            = 0.1;  % Gradient Proj stopping tolerance.
  if p_flag == 1
    Opt_params.cg_tol          = 0.25;   % CG stopping tolerance with precond.
  else
    Opt_params.cg_tol          = 0.1;   % CG stopping tolerance w/o precond.
  end
  Opt_params.linesrch_param1   = 0.1;  % Update parameters for quadratic 
  Opt_params.linesrch_param2   = 0.5;  %   backtracking line search. 
  Opt_params.linesrch_gp       = 'linesrch_gp';  % Line search function.
  Opt_params.linesrch_cg       = 'linesrch_cg';  % Line search function.  

%------------------------------------------------------------------------
%  Declare and initialize global variables.
%------------------------------------------------------------------------
  
  global TOTAL_COST_EVALS TOTAL_GRAD_EVALS TOTAL_HESS_EVALS TOTAL_FFTS
  global TOTAL_PRECOND_SETUPS TOTAL_PRECOND_EVALS
  global TOTAL_FFT_TIME TOTAL_PRECOND_TIME
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
  [f,histout] = gpnewton(f_0,Opt_params,Cost_params,Data);
  total_cpu_time = cputime - cpu_t0;
    
%---------------------------------------------------------------------
%  Display results.
%---------------------------------------------------------------------
    
  f_poisson = reshape(f,nx,ny);
  f_true = Data.object;
    
    figure(5)
      imagesc(f_poisson), colorbar
      %title('Reconstructed Object')
      
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

    poiss_rel_err = norm(f_poisson-f_true,'fro')/norm(f_true(:));
    fprintf('Relative soln error             = %f\n',poiss_rel_err);
    fprintf('Total cost function evaluations = %d\n',TOTAL_COST_EVALS);
    fprintf('Total grad function evaluations = %d\n',TOTAL_GRAD_EVALS);
    fprintf('Total Hess function evaluations = %d\n',TOTAL_HESS_EVALS);
    fprintf('Total fast fourier transforms   = %d\n',TOTAL_FFTS);
    fprintf('Total preconditioner setups     = %d\n',TOTAL_PRECOND_SETUPS);
    fprintf('Total preconditioner evals      = %d\n',TOTAL_PRECOND_EVALS);
    fprintf('Total CPU time, in seconds      = %d\n',total_cpu_time);
    fprintf('FFT CPU time                    = %d\n',TOTAL_FFT_TIME);
    fprintf('Preconditioning time            = %d\n',TOTAL_PRECOND_TIME);
