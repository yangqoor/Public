% Setup.m
%
  clear all, randn('state',0);   %  Reset random number generator to initial state.
% -------------------------------------------------------------
% Generate true image and forward model
% -------------------------------------------------------------

  nx = 64; ny = 64;
  [f_true,Aparams]=Satellite(nx,ny);

% -------------------------------------------------------------
% Generate noisy data. 
% -------------------------------------------------------------
  Af_true = Amult(f_true,Aparams);
  randn('state',0); n=nx*ny;
  stdev  = 5;%input(' Std. deviation of Gaussian error in data = ');
  bkgrnd = 10;%input(' Background count Poisson parameter = ');
  d = poissrnd(Af_true) + poissrnd(bkgrnd*ones(nx,ny)) ...
        + stdev*randn(nx,ny);
  SNR = norm(Af_true(:)) / sqrt(stdev^2*n + sum(Af_true(:)+bkgrnd+bkgrnd^2)) 
  
%------------------------------------------------------------------------
%  Save data in structure array Data.
%------------------------------------------------------------------------
  Data.nx              = nx;
  Data.ny              = ny;
  Data.Aparams         = Aparams;
  Data.gaussian_stdev  = stdev;
  Data.Poiss_bkgrnd    = bkgrnd;
  Data.object          = f_true;
  Data.noise_free_data = Af_true;
  Data.noisy_data      = d;

%------------------------------------------------------------------------
%  Display data.
%------------------------------------------------------------------------
  figure(1)
    imagesc(f_true)
    colorbar
    title('Object (True Image)')
  figure(2)
    imagesc(d)
    colorbar
    title('Blurred, Noisy Image')


