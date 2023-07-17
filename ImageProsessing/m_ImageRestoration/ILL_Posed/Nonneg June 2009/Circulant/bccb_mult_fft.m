  function y = bccb_mult_fft(x,t_hat)

%
%  Compute y = BCCB(t)*x using 2-D FFTs. t_hat = fft2(t).

  global TOTAL_FFTS TOTAL_FFT_TIME
  TOTAL_FFTS = TOTAL_FFTS + 2;

  [Nx,Ny] = size(t_hat);
  [nx,ny] = size(x);
  if (Nx ~= nx | Ny ~= ny)
    fprintf('*** Row and col dim of 1st arg must equal that of 2nd arg.\n');
    return
  end

  cpu_t0 = cputime;
  y = real(ifft2( t_hat .* fft2(x) ));
  TOTAL_FFT_TIME = TOTAL_FFT_TIME + (cputime - cpu_t0);
