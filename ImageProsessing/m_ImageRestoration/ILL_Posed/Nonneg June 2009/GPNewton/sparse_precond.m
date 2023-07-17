  function [y,params] = sparse_precond(r,Active,params)
%
%  In case of a single output argument, compute y = M^{-1}r, where 
%  M is the preconditioning matrix, using the reordered Cholesky
%  factorization of M.
%
%  In case of two output arguments, build preconditioning matrix M and
%  compute its reordered Cholesky factorization.

  global TOTAL_PRECOND_SETUPS TOTAL_PRECOND_EVALS TOTAL_PRECOND_TIME
  Inactive = 1 - Active(:);
  mask_index = find(Inactive == 1);
    
  if nargout == 2  %  Compute and store reordered Choleski factorization.

    TOTAL_PRECOND_SETUPS = TOTAL_PRECOND_SETUPS + 1;
    T_sparse = params.sparse_approx;
    alpha    = params.reg_param;
    L        = params.reg_operator;
    d        = params.data;
    sig      = params.gaussian_stdev;
    Tfpc     = params.Tfpc;
    [nx,ny] = size(d);
    n = nx*ny;
    cpu_t0 = cputime;
    W = (d + sig^2) ./ Tfpc.^2;
    W_mat = spdiags(W(:), 0, n,n);
    M = T_sparse' * W_mat * T_sparse + alpha * L;
    M = M(mask_index,mask_index);
    p = symamd(M);
    R = chol(M(p,p));
    I = speye(size(M));
    Ip = I(:,p);  %  Inverse of permutation matrix.
    TOTAL_PRECOND_TIME = TOTAL_PRECOND_TIME + (cputime - cpu_t0);
    params.permutation = p;
    params.inverse_P = Ip;
    params.choleski_factor = R;
    y = [];
    
  else  %  yR = M\r;
  
    TOTAL_PRECOND_EVALS = TOTAL_PRECOND_EVALS + 1;
    r = r(:);
    cpu_t0 = cputime;
    r = r(mask_index);
    [Nx,Ny] = size(Active);
    y = zeros(Nx*Ny,1);
    p = params.permutation;
    Ip = params.inverse_P;
    R = params.choleski_factor;
    yR = Ip * (R \ (R' \ r(p)));
    y(mask_index) = yR;
    y = reshape(y,Nx,Ny);
    TOTAL_PRECOND_TIME = TOTAL_PRECOND_TIME + (cputime - cpu_t0);
    
  end
  
