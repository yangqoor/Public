% This file describes how to use this suite of codes on simulated satellite 
% data. This is the example used in the Poisson likelihood works of 2007-09.
% Also included is the implementation of regularization parameter selection
% methods. 

- Johnathan M. Bardsley and Aaron Luttman, "Total Variation-Penalized 
Poisson Likelihood Estimation for Ill-Posed Problems," UM-Tech Report #8 
2006.

- Johnathan M. Bardsley and N'djekornom Laobeul, "Tikhonov Regularized 
Poisson Likelihood Estimation: Theoretical Justification and a Computational 
Method," UM-Tech Report #16 2006.

- Johnathan M. Bardsley, "Poisson Inverse Problems with Total Variation 
Prior: Statistical Motivation and an Efficient Computational Method," 
UM-Tech Report # 2007.

_ Johnathan M. Bardsley and John Goldes, "An Iterative Method for Edge-Preserving 
MAP Estimation when Data-Noise is Poisson, SIAM Journal on Scientific Computing, accepted. 
University of Montana Technical Report #26, 2008.

-Johnathan M. Bardsley and John Goldes, "Regularization Parameter Selection 
Methods for Ill-Posed Poisson Maximum Likelihood
Estimation," UM Tech Report # 2009

First, to set directory paths, type

>> startup

% For the example in the 2004 SISC paper, see ReadmeNonneg04.txt. 

***** To generate synthetic satellite data for simulations. *****

>> SetupSatellite
 Object size nx = 64
 Enter 0 for Toeplitz and 1 for Circulant blurring matrix. 0
 ... generating image data ...
>> Data = setup_toeplitz(psf,f_true);

SNR =

   30.6608

***** Deblurring Algorithms *****
NOTE: You may have to change some of the internal optimization parameters
to match results in the papers.

1. *** Poisson Likelihood ***  
      a. GPRLD for Poisson Total Variation
      >> Min_poisson
       Enter 1 for DP, 2 for GCV, 3 for UPRE, or 4 for no method 4
       Regularization parameter = 1e-5
       Enter 0 for Tikhonov; 1 for TV; and 2 for Laplacian. 1
       Enter 1 for preconditioning; else enter 0: 1
       ... setting up preconditioner ...
       Reset initial guess? (0 = no; 1 = yes): 1

      b. GPRNCG for Poisson Tikhonov
        >> Min_poisson
         Enter 1 for DP, 2 for GCV, 3 for UPRE, or 4 for no method 4
         Regularization parameter = 1e-5
         Enter 0 for Tikhonov; 1 for TV; and 2 for Laplacian. 0
         Enter 1 for preconditioning; else enter 0: 0
         Reset initial guess? (0 = no; 1 = yes): 1
      
	c. GPRN for Poisson Diffusion Regularization
	>> Min_poisson
	 Enter 1 for DP, 2 for GCV, 3 for UPRE, or 4 for no method 4
	 Regularization parameter = 1e-5
	 Enter 0 for Tikhonov; 1 for TV and 2 for Laplacian. 2
	 Enter 0 for regular Laplacian and 1 for diffusion coefficient computed from f_poisson. 0
	>> Min_poisson
	 Enter 1 for DP, 2 for GCV, 3 for UPRE, or 4 for no method 4
	 Regularization parameter = 1e-5
	 Enter 0 for Tikhonov; 1 for TV and 2 for Laplacian. 2
	 Enter 0 for regular Laplacian and 1 for diffusion coefficient computed from f_poisson. 1

	d. GPRN for Poisson Tikhonov with GCV Recommendation 
	>> Min_poisson
	 Enter 1 for DP, 2 for GCV, 3 for UPRE, or 4 for no method 2
       enter lower-bound for search region 0
	 enter upper-bound for search region 1e-4
	 Enter 0 for Tikhonov; 1 for TV and 2 for Laplacian. 0

	e. EM or Richardson-Lucy
        >> EM

2. *** Least squares likelihood *** 
      a. GPRLD for WEIGHTED Least Squares Total Variation
        >> Min_wls
         Regularization parameter = 5e-5
         Enter 0 for Tikhonov; 1 for TV; and 2 for Laplacian. 1
         Enter 1 for weighted ls; enter 0 otherwise: 1
         Enter 1 for preconditioning; else enter 0: 1
         Enter 1 to create sparse PSF and 0 otherwise. 0
         Reset initial guess? (0 = no; 1 = yes): 1

      b. Lagged-Diffusivity fixed point iteration
        >> Min_ld
         Regularization parameter = 5e-2
         Enter 1 for weighted ls; enter 0 otherwise: 0
         Max number of iterations = 100
         Max CG iterations = 30
         Reset initial guess? (0 = no; 1 = yes): 1

      c. GPRLD for REGULAR Least Squares Total Variation
        >> Min_wls
         Regularization parameter = 5e-5
         Enter 0 for Tikhonov; 1 for TV; and 2 for Laplacian. 1
         Enter 1 for weighted ls; enter 0 otherwise: 0
         Enter 1 for preconditioning; else enter 0: 1
         Enter 1 to create sparse PSF and 0 otherwise. 0
         Reset initial guess? (0 = no; 1 = yes): 1

      d. GPCG for WEIGHTED and REGULAR Least Squares Tikhonov
        >> Min_gpcg_wls

***** To generate the data for the denoising problem. *****

>> SetupCamera
>> Data = setup_circulant(psf,f_true);
 Std. deviation of Gaussian error in data = 5
 Enter 1 for Poisson noise and 0 otherwise. 1
 Background count Poisson parameter = 0

***** TV Denoising Algorithms *****
NOTE: You may have to change some of the internal optimization parameters
to match results in the papers.

GPRLD with Poisson, weighted least squares, and regular least squares 
likelihood as well as lagged-diffusivity are appropriate here. The values 
for the regularization parameter the paper were 3e-4 for the Poisson and 
weighted least squares likelihood and 3e-3 for the least squares 
likelihood.
