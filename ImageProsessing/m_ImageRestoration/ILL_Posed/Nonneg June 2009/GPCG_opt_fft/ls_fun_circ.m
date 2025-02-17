  function [J,Params,g] = ls_fun(f,Params)
  
%  Evaluate penalized, weighted least squares cost functional
%      J(f) = .5*[(T*f-d)'*W*(T*f-d) + alpha*f'*L*f]
%  and the gradient  
%      g(f) = T'*W*(T*f-d) + alpha*L*f.
%
%  Declare global variables and initialize parameters and vectors.

  global TOTAL_COST_EVALS TOTAL_GRAD_EVALS TOTAL_FFT_TIME TOTAL_FFTS

  gam     = Params.reg_param;
  t_hat   = Params.blurring_operator;
  D       = Params.fft_data;
  L       = Params.reg_operator;
  nx      = Params.nx;
  ny      = Params.ny;
  const   = Params.const;
  
%  Compute J(f).  

  cpu_t0 = cputime;  
  Fourier_f = fft2(f);
  TOTAL_FFT_TIME = TOTAL_FFT_TIME + (cputime - cpu_t0);  
  TOTAL_FFTS = TOTAL_FFTS + 1;
  temp_i = t_hat.*Fourier_f;
  Fresid_i = temp_i - D;
  Params.Fresid = Fresid_i;
  Lf = L*f(:);
  J = (.5/const)*norm(1/sqrt(nx*ny)*Fresid_i(:))^2 + .5*gam*f(:)'*Lf;
  TOTAL_COST_EVALS = TOTAL_COST_EVALS + 1;

%  Compute grad J(f).
  
  if nargout == 3       % Then output fft(resid) and the gradient.
    g_temp = conj(t_hat).*((1/const)*Fresid_i);
    cpu_t0 = cputime;
    iFg_temp = ifft2(g_temp);
    TOTAL_FFT_TIME = TOTAL_FFT_TIME + (cputime - cpu_t0);  
    TOTAL_FFTS = TOTAL_FFTS + 1;
    g = real(iFg_temp)+gam*reshape(Lf,nx,ny);
    TOTAL_GRAD_EVALS = TOTAL_GRAD_EVALS + 1;
  end
