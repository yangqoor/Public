  function y = cg_bccb_mult_fft(x,params)

%
%  Compute y = y = D_alpha(T'C^(-1/2)T+alphaL)D_alpha*x
%  when T is BCCB

%
 t_hat=params.blurring_operator;
  D_alpha = params.D_alpha;
  L = params.reg_operator;
  alpha = params.reg_param;
  W = params.WeightMat;
  n = params.nx;
  x = reshape(x,n,n);

  global TOTAL_FFTS TOTAL_FFT_TIME
  TOTAL_FFTS = TOTAL_FFTS + 2;

  [Nx,Ny] = size(t_hat);
  [nx,ny] = size(x);
  if (Nx ~= nx | Ny ~= ny)
    fprintf('*** Row and col dim of 1st arg must equal that of 2nd arg.\n');
    return
  end

  cpu_t0 = cputime;
  
  Dax = D_alpha.*x;
  Tx = real(ifft2( t_hat .* fft2(Dax) ));
  WTx = W.*Tx;
  TWTx = real(ifft2( conj(t_hat) .* fft2(WTx) ));
  aLx = reshape(alpha*L*Dax(:),n,n);
  yy = D_alpha.*(TWTx+aLx);
  y = yy(:);
  TOTAL_FFT_TIME = TOTAL_FFT_TIME + (cputime - cpu_t0);
