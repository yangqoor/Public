  function y = cg_bttb_mult_fft(x,params)

%
%  Compute y = D_alpha(T'C^(-1/2)T+alphaL)D_alpha*x
%  when T is BTTB
%  
  global TOTAL_FFTS TOTAL_FFT_TIME
  TOTAL_FFTS = TOTAL_FFTS + 2;
  t_hat=params.blurring_operator;
  D_alpha = params.D_alpha;
  L = params.reg_operator;
  alpha = params.reg_param;
  W = params.WeightMat;
  n = params.nx;
  x = reshape(x,n,n);
  [Nx,Ny] = size(t_hat);
  [Nxd2,Nyd2] = size(x);

  if (Nx/2 ~= Nxd2 | Ny/2 ~= Nyd2)
    fprintf('*** Row and col dim of 1st arg must be half that of 2nd arg.\n');
    return
  end
  x=D_alpha.*x;
  %  Extend x by zeros.
  
  x_extend = zeros(Nx,Ny);
  x_extend(1:Nxd2,1:Nyd2) = x;

  %  Compute product using FFTs; then restrict.
  
  cpu_t0 = cputime;
  y_extend = real(ifft2( t_hat .* fft2(x_extend) ));

  y_extend(1:Nxd2,1:Nyd2)= W.*y_extend(1:Nxd2,1:Nyd2);
   y_extend = real(ifft2( conj(t_hat) .* fft2(y_extend) ));
  TOTAL_FFT_TIME = TOTAL_FFT_TIME + (cputime - cpu_t0);
  yy = y_extend(1:Nxd2,1:Nyd2);
  yy = D_alpha.*yy;
  aLx = alpha*L*x(:);
  aLx = reshape(aLx,Nxd2,Nyd2);
  aLx = D_alpha.*aLx;
  y = yy(:) + aLx(:);


