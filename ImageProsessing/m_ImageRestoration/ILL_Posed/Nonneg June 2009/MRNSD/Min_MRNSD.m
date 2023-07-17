%  Min_MRNSD.m
%
%  Minimize least squares functional
%    J(x) = ||T*x-d||^2
%  subject to nonnegativity constraints.
%  T is the blurring operator and d is the data.
%
%  USE CIRCULANT DATA WITH I.I.D. GAUSSIAN NOISE, CONSTANT VARIANCE!!

  if Data.type == 'toep'
    disp('STOP!!! You need to use circulant data. See Readme file.')
    return
  end

%------------------------------------------------------------------------
%  Set up parameters and data to evaluate cost function and its
%  Hessian. Store information in structure array Cost_params. 
%------------------------------------------------------------------------

  Cost_params.nx                = Data.nx;
  Cost_params.ny                = Data.ny;
  Cost_params.data              = Data.noisy_data;
  Cost_params.blurring_operator = Data.BCCB_kernel_fft;

%------------------------------------------------------------------------
%  Set up and store optimization parameters in structure array Opt_params.
%------------------------------------------------------------------------

  Opt_params.max_iter    = 10; %%%input(' Max number of iterations = ');
  Opt_params.tol         = 1e-3;  % termination criterion: norm(step)
  Opt_params.f_true      = Data.object; % True image.
  
%------------------------------------------------------------------------
%  Declare and initialize global variables.
%------------------------------------------------------------------------
  
  global TOTAL_FFTS TOTAL_FFT_TIME
  TOTAL_FFTS = 0;
  TOTAL_FFT_TIME = 0;

%---------------------------------------------------------------------
%  Set initial guess.
%---------------------------------------------------------------------
  
  init_flag = input(' Reset initial guess? (0 = no; 1 = yes): ');
  if init_flag == 1        % Reset initial guess
    f_0 = Data.noisy_data; 
  else
    f_0 = f;
  end

%---------------------------------------------------------------------
%  Solve minimization problem.
%---------------------------------------------------------------------
  
  cpu_t0 = cputime;
  [f,Rnrm,Xnrm,Enrm,fftvec] = MRNSD(f_0,Opt_params,Cost_params);
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
      semilogy(fftvec,Enrm,'o-')
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
