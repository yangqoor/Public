  function [y,params] = sparse_wls_precond(r,Active,params)
%
%  In case of a single output argument, compute y = M^{-1}r, where 
%  M is the preconditioning matrix, using the reordered Cholesky
%  factorization of M.
%
%  In case of two output arguments, compute a reordered Cholesky
%  factorization of M.

  global TOTAL_PRECOND_SETUPS TOTAL_PRECOND_EVALS TOTAL_PRECOND_TIME
  Inactive = 1 - Active(:);
  mask_index = find(Inactive == 1);
    
  if nargout == 2  %  Compute and store reordered Choleski factorization.

    TOTAL_PRECOND_SETUPS = TOTAL_PRECOND_SETUPS + 1;
    M = params.precond_matrix;
    cpu_t0 = cputime;
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
  
