 function [psf,psf_hat] = psf_interp(psf0)
 
%  [psf,psf_hat] = psf_interp(psf0)
%
%  Interpolate Fourier transformed psf onto finer grid.
%  Assume psf0_hat = fft2(psf0) is real-valued and radially symmetric.

  psf0_hat = real(fft2(fftshift(psf0)));
  dc = psf0_hat(1,1);
  psf0 = (1/dc) * psf0;
  psf0_hat = (1/dc) * psf0_hat;
  khat = fftshift(real(psf0_hat));
  [nx,ny] = size(psf0);
  nxd2 = nx/2;
  z0 = khat(nxd2+1,nxd2+1:nx)';
  z0 = max(z0,0);
  z0 = [z0; zeros(nx+1,1)];
  r0 = [0:nx+nxd2]';
  
  x = [-nxd2:.5:nxd2-.5]';
  [x,y] = meshgrid(x);
  r = sqrt(x.^2 + y.^2);
  psf_hat = interp1(r0,z0,r(:));
  psf_hat = reshape(psf_hat,2*nx,2*ny);
  psf = fftshift(real(ifft2(fftshift(psf_hat))));
  
  figure(1)
    imagesc(fftshift(psf0_hat)), colorbar
    title('Power Spectrum of PSF')
  figure(2)
    imagesc(psf_hat), colorbar
    title('Interpolated Power Spectrum')

  figure(3)
    imagesc(psf0), colorbar
    title('PSF')
  figure(4)
    imagesc(psf), colorbar
    title('Interpolated PSF')
  
  