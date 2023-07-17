  function [Hx] = wls_hess(Params,x);
  
%  Compute penalized, weighted least squares matrix-vector product
%  H*x, where
%      H = T'*W*T + alpha*L.

  global TOTAL_HESS_EVALS TOTAL_FFT_TIME TOTAL_FFTS
  TOTAL_HESS_EVALS = TOTAL_HESS_EVALS + 1;
  TOTAL_FFTS = TOTAL_FFTS + 2;

%  Initialize parameters and vectors.

  t_hat   = Params.blurring_operator;
  gam     = Params.reg_param;
  L       = Params.reg_operator;
  nx      = Params.nx;
  ny      = Params.ny;
  const   = Params.const;
  
%  Compute Hessian vector product.
  
  cpu_t0 = cputime;
  Fourier_x = fft2(x);
  TOTAL_FFT_TIME = TOTAL_FFT_TIME + (cputime - cpu_t0);  
  cT_T_Fx = (1/const)*conj(t_hat).*(t_hat.*Fourier_x);
  Lx = L*x(:);  
  cpu_t0 = cputime;
  iF_cT_T_Fx = ifft2(cT_T_Fx);
  TOTAL_FFT_TIME = TOTAL_FFT_TIME + (cputime - cpu_t0);  
  Hx = real(iF_cT_T_Fx) + gam*reshape(Lx,nx,ny);
