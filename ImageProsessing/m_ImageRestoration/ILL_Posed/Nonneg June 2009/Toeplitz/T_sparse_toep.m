  function[T_sparse] = T_sparse_toep(array2mat,sparse_psf)

%  Get sparse preconditioner.

       T_sparse = sparse(feval(array2mat,sparse_psf));
  %%%     load T_toep_psf073_128   
  %%%     load T_sparse_Setup64_12_1_06