  function Data = setup_circulant2(psf,object)
  
%  Data = setup_circulant(psf,object)
%
%  Simulate astronomical image data using model
%    d = C*f_true + noise,
%  where C is block circulant with circulant blocks (BCCB).
%  The following noise model is used: For i=1,...,n,
%    d_i ~ poisson([Tf_true]_i) + poisson(bkgrnd) + normal(0,stdev^2). 
%  Each of the 3 error terms is independent, and the components d_i
%  are each independent. The second term models sky background
%  radiation, and the third term models detector read noise.

%------------------------------------------------------------------------
%  Rescale PSF so corresponding operator T preserves means.
%------------------------------------------------------------------------

  psf_hat = fft2(fftshift(psf));
  dc = psf_hat(1,1);
  psf = (1/dc) * psf;
  psf_hat = (1/dc) * psf_hat;
  [nx,ny] = size(psf);
  n = nx*ny;

%------------------------------------------------------------------------
%  Get object.
%------------------------------------------------------------------------

  f_true = extract(object,nx,ny);
  choice = input('Enter 1 for satellite or 2 for starfield ');
%------------------------------------------------------------------------
%  Generate simulated image data according to the model
%      d ~ Poisson(C*f_true) + Poisson(bkgrnd) + Normal(0,stdev^2),
%  where C = BCCB(t) is an nx X ny matrix.
%------------------------------------------------------------------------
  
  %  Compute C*f_true via block circulant extension.

 % Cf_true = bccb_mult_fft(f_true,psf_hat);

  %  Generate noisy data. First initialize random number generator.
  
  randn('state',0);
  
  stdev  = 5;%input(' Std. deviation of Gaussian error in data = ');
  %Poiss_flag = input(' Enter 1 for Poisson noise and 0 otherwise. ');
% if Poiss_flag == 1
    %SNR = norm(Cf_true(:)) / sqrt(stdev^2*n + sum(Cf_true(:)+bkgrnd)) 
 % else
  
 %   d = Cf_true + stdev*randn(nx,ny);
 %   SNR = norm(Cf_true(:)) / sqrt(stdev^2*n) 
 % end
   choice3 = input(' Enter 1, 5, 10, 30, or 100 for the SNR value. ');
  v = [1, 5, 10, 30, 100]; vsat = [.0146 .0876 .2147 1.2855 12.9158]; vstar = [0.35 1.8 3.6 13 69];
  ii = find(v==choice3);
  if choice==1, scale = vsat(ii); else scale=vstar(ii); end
  f_true = scale*f_true;
  Cf_true = bccb_mult_fft(f_true,psf_hat);
   bkgrnd = 10;%input(' Background count Poisson parameter = ');
  
  SNR = norm(Cf_true(:)+bkgrnd) / sqrt(stdev^2*n + sum(Cf_true(:)+bkgrnd))

    d = poissrnd(Cf_true) + poissrnd(bkgrnd*ones(nx,ny)) ...
          + stdev*randn(nx,ny);
 
%------------------------------------------------------------------------
%  Save data in structure array Data.
%------------------------------------------------------------------------

  Data.type            = 'circ';
  Data.nx              = nx;
  Data.ny              = ny;
  Data.BCCB_kernel     = psf;
  Data.BCCB_kernel_fft = psf_hat;
  Data.gaussian_stdev  = stdev;
  Data.Poiss_bkgrnd    = bkgrnd;
  Data.object          = f_true;
  Data.noise_free_data = Cf_true;
  Data.noisy_data      = d;

%------------------------------------------------------------------------
%  Display data.
%------------------------------------------------------------------------

  figure(1)
  colormap(hot)
  subplot(221)
      imagesc(psf)
      colorbar
      title('Point Spread Function')
  subplot(222)
      imagesc(fftshift(log(abs(psf_hat)+sqrt(eps))))
      colorbar
      title('Log_{10} of Power Spectrum of PSF')
  subplot(223)
      imagesc(f_true)
      colorbar
      title('Object (True Image)')
  subplot(224)
      imagesc(d)
      colorbar
      title('Blurred, Noisy Image')

