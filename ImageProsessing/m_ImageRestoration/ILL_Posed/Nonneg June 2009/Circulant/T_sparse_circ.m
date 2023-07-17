  function[T_sparse] = T_sparse_circ(array2mat,sparse_psf)

%  Get sparse preconditioner.

  T_sparse = sparse(feval(array2mat,sparse_psf));

  % Use pregenerated sparse matrix
  %fprintf(' Loading data file T_circ_psf073_128\n')
  %load T_circ_psf073_128   
