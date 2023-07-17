  function Data = setup_toeplitz(psf,object)
  
%  Data = setup_toeplitz(psf,object)
%
%  Simulate astronomical image data using model
%    d = T*f_true + noise,
%  where T is block Toeplitz with Toeplitz blocks (BTTB).
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
  [nxt2,nyt2] = size(psf);

%------------------------------------------------------------------------
%  Get object.
%------------------------------------------------------------------------

  nx = nxt2/2;
  ny = nyt2/2;
  n = nx*ny;
  f_true = extract(object,nx,ny);

%------------------------------------------------------------------------
%  Generate simulated image data according to the model
%      d ~ Poisson(T*f_true) + Poisson(bkgrnd) + Normal(0,stdev^2),
%  where T = BTTB(t) is an nx X ny matrix.
%------------------------------------------------------------------------
  
  %  Compute T*f_true via block circulant extension.
  Tf_true = bttb_mult_fft(f_true,psf_hat);
 choice_fig=input('1 for satellite or 2 for star cluster '); 
  %  Generate noisy data.
  if choice_fig==1
choice = input('For SNR choose 1 5 10 30 100 ');
if choice == 1
    scalesat = .0194
    f_true = scalesat*f_true;
elseif choice== 5
    scalesat = .055;
    f_true = scalesat*f_true;
elseif choice== 10
    scalesat = .109;
    f_true = scalesat*f_true;
elseif choice == 30
    scalesat = .7;
    f_true = scalesat*f_true;
elseif choice == 100
    scalesat = 6.55;
    f_true = scalesat*f_true;
    
end
  elseif choice_fig== 2;
      choice=input('For SNR choose 1 5 10 30 100 ');
      if choice == 100
          scalesf = 112.428;
          f_true=scalesf*f_true;
      elseif choice == 30
          scalesf = 12.7;
          f_true=scalesf*f_true;
      elseif choice == 10
          scalesf = 2.5296;
          f_true=scalesf*f_true;
      elseif choice == 5
          scalesf = 1.25
          f_true=scalesf*f_true;
      elseif choice == 1
          scalesf = .4838
          f_true=scalesf*f_true;
      

          

      end
  end
Tf_true = bttb_mult_fft(f_true,psf_hat);
  
randn('state',0);
  stdev  = 5; %%%input(' Std. deviation of Gaussian error in data = ');
  bkgrnd = 10; %%%input(' Background count Poisson parameter = ');
  d = poissrnd(Tf_true) + poissrnd(bkgrnd*ones(nx,ny)) ...
        + stdev*randn(nx,ny);
  SNR = norm(Tf_true(:)+bkgrnd) / sqrt(stdev^2*n + sum(Tf_true(:)+bkgrnd)) 

  %  Check that data d + stdev^2 is "safely positive".
  
  if min(d(:)) < -stdev^2 + sqrt(eps)
    fprintf('*** Warning: Data not safely positive.\n');
  end
  
%------------------------------------------------------------------------
%  Save data in structure array Data.
%------------------------------------------------------------------------

  Data.type            = 'toep';
  Data.nx              = nx;
  Data.ny              = ny;
  Data.BTTB_kernel     = psf(2:nxt2,2:nyt2);
  Data.BTTB_kernel_fft = psf_hat;
  Data.gaussian_stdev  = stdev;
  Data.Poiss_bkgrnd    = bkgrnd;
  Data.object          = f_true;
  Data.noise_free_data = Tf_true;
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

