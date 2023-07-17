  function[f_true,Aparams] = ImageModel(nx,ny)
  
% -------------------------------------------------------------
% Generate the true image.
% -------------------------------------------------------------

  h = 2/(nx-1);
  x = [-1:h:1]';
  [X,Y] = meshgrid(x);
  R = sqrt(X.^2 + Y.^2);
  f1 = (R<.25);
  f2 = (-.2<X-Y) & (X-Y<.2) & (-1.4<X+Y) & (X+Y<1.4);
  f3 = (-.2<X+Y) & (X+Y<.2) & (-1.4<X-Y) & (X-Y<1.4);
  panel = f2.*(1-f1) + f3.*(1-f1);
  f4 = (-.25<X) & (X<.25) & (0<Y) & (Y<.5);
  f5 = (sqrt(X.^2+(Y-.5).^2) < .25);
  body = .5*f1 + (f4.*(1-f1) + f5.*(1-f4));
  body_support = (body>0);
  f_true = .75*panel + body.*(1-panel);
  f_true = f_true';
  % Add some texture
  f_true = f_true+ .1*exp(-((X-x(ceil(nx/6))).^2+(Y - x(nx/2)).^2)/(2*.001));
  f_true = f_true+ .3*exp(-((X-x(nx/2)).^2+(Y - x(ceil(nx/8))).^2)/(2*.0001));
  f_true = f_true+ .15*exp(-((X-x(nx/2)).^2+(Y - x(ceil(nx/4))).^2)/(2*.0001));
  f_true = f_true + (((X-x(nx/2)).^2 + (Y-x(nx-ceil(nx/6))).^2) <= .05) .* sqrt( .05 - (X-x(nx/2)).^2 - (Y-x(nx-ceil(nx/6))).^2);
  c_f = 5e3;
  f_true = c_f * f_true;
  
% -------------------------------------------------------------
% Generate what you need for forward model.
% -------------------------------------------------------------
  icen = nx/2 + 1;  % Pupil is centered at icen. 
  ix = [1:nx]' - icen;  iy = [1:ny]' - icen;
  [iX,iY] = meshgrid(ix,iy);
  R = nx/2;  r = sqrt(iX.^2 + iY.^2) / R;
  pupil = (.1 < r & r < .5);

% Generate phase screen.
  L0m2 = 1e-4 / R;  c_phi = 20*pi;
  indx = [0:nx/2, ceil(nx/2)-1:-1:1]';
  [indx1,indx2] = meshgrid(indx,indx');
  phi = real(ifft2( (sqrt(indx1.^2+indx2.^2).^2 + L0m2).^(-11/12) .* ...
      fft2(randn(nx,ny)) ));
  phi = phi - mean(phi(:));
  phi = c_phi * phi .* pupil;
  
% Generate point spread function.
  imath = sqrt(-1);
  H = fftshift( pupil.*exp(imath*phi));
  psf = abs(ifft2(H)).^2;
  psf_hat = fft2(psf);
  psf = fftshift(psf);
  dc = psf_hat(1,1);
  psf = (1/dc) * psf;
  psf_hat = (1/dc) * psf_hat;
  Aparams = psf_hat;
  
