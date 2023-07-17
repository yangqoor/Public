  function Kf = convolve_2D(k_hat,f,nfx,nfy)
%
%  Kf = convolve_2D(k_hat,f,nfx,nfy)
%
%  Evaluate the 2-D convolution product
%
%    Kf(i,j) = sum_{i'=1,...,nx} sum_{j'=1,...,ny} k(i-i',j-j')*f(i',j').
%
%  k_hat = DFT(k), the 2-D discrete Fourier transform of the discrete
%  convolution kernel k. k is assumed to be (nx,ny)-periodic, and  
%    Kf = DFT^{-1}(k_hat .* DFT(f)).
%  k_hat and f need not be the same size. If not, f is extended by zeros.

  [nkx,nky] = size(k_hat);
  Kf = real(ifft2( ((k_hat .* fft2(f,nkx,nky)) )));
  
%  If 4 arguments are passed, only the upper left nfx X nfy subblock
%  of the array Kf is returned.
  
  if nargin == 4
    Kf = Kf(1:nfx,1:nfy);
  end