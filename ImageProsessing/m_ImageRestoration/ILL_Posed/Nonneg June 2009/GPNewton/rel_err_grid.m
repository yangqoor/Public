%  Min_poisson.m
%
%  Minimize penalized Poisson log likelihood functional
%    J(x) = sum(Txps - d.*log(Txps)) + alpha/2*x'*L*x
%  subject to nonnegativity constraints. Here 
%    Txps = T*x + sigma^2,
%  T is the blurring operator, d is the data, alpha is the
%  regularization parameter, L is the regularization matrix, and
%  sigma is a positive parameter.
clear Cost_params Opt_params
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
  if Cost_params.reg_choice == 2;
     diffusion_flag = input(' Enter 0 for regular Laplacian and 1 for scaling computed from approximate. ');
     if diffusion_flag == 1 
       [Fxf,Fyf]=gradient(f_poisson);
       absGrad = Fxf.^2+Fyf.^2;
       thresh = absGrad.*(absGrad>0.01*max(absGrad(:)));
       Ddiag = max(1./(1+thresh),0.1);%eps^(1/2)/alpha);
       Dmat = spdiags(Ddiag(:),0,n,n);
       L=DiffusionMatrix(nx,ny,Dmat);
     else
       %L=DiffusionMatrix(nx,ny,speye(n,n));
       L=laplacian(nx,ny);
     end
     Cost_params.reg_operator = L;
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
  Cost_params.cost_fn           = 'poisslhd_fun';
  Cost_params.hess_fn           = 'poisslhd_hess';
  Cost_params.data              = Data.noisy_data;
  Cost_params.reg_param         = alpha;
  Cost_params.gaussian_stdev    = Data.gaussian_stdev;
  Cost_params.Poiss_bkgrnd      = Data.Poiss_bkgrnd;
  if Data.type == 'toep'
    Cost_params.Tmult_fn          = 'bttb_mult_fft';
    Cost_params.blurring_operator = Data.BTTB_kernel_fft;
    Cost_params.tflag             = 0;
  elseif Data.type =='circ'  % type = 'circ'
    Cost_params.Tmult_fn          = 'bccb_mult_fft';
    Cost_params.blurring_operator = Data.BCCB_kernel_fft;
  else
        Cost_params.Tmult_fn          = 'Amult_PET';
        Aparams = Data.Aparams;
        A = Aparams.A;
    Cost_params.blurring_operator = A;
    
    Cost_params.tflag             = 1;
  end
  
%------------------------------------------------------------------------
%  Build and store preconditioner.
%------------------------------------------------------------------------

  p_flag = 0;%input(' Enter 1 for preconditioning; else enter 0: ');
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
    Cost_params.precond_fn = 'sparse_precond';
    Cost_params.sparse_approx = T_sparse;
    Cost_params.start_prec = 5;  %  Iteration at which to start preconditioning.
  end
  
%------------------------------------------------------------------------
%  Set up and store optimization parameters in structure array Opt_params.
%------------------------------------------------------------------------

  Opt_params.max_iter          = 100;  %input(' Max number of iterations = ');
  Opt_params.step_tol          = 1e-6;  % termination criterion: norm(step)
  Opt_params.grad_tol          = 1e-6;  % termination criterion: rel norm(grad)
  Opt_params.max_gp_iter       = 5;  %input(' Max gradient projection iters = ');
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
  
  init_flag = 1;%input(' Reset initial guess? (0 = no; 1 = yes): ');
  if init_flag == 1        % Reset initial guess
    f_0 = ones(nx,ny);
  else
    f_0 = f;
  end

%---------------------------------------------------------------------
%  Solve minimization problem.
%---------------------------------------------------------------------
  alphavec = logspace(-12,-2);
  relerrorvec = [];
for i=1:length(alphavec)
      alpha = alphavec(i);
      Cost_params.reg_param=alpha;
  [f,histout] = gpnewton(f_0,Opt_params,Cost_params,Data);
    f_poisson = reshape(f,nx,ny);
  f_true = Data.object;
  relerrorvec = [relerrorvec norm(f_true(:)-f_poisson(:))/norm(f_true(:))];
end
  %---------------------------------------------------------------------
%  Display results.
%---------------------------------------------------------------------
 figure   
 semilogx(alphavec,relerrorvec)
    
   