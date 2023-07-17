This directory contains the codes that were used to obtain results
from the paper 

J. M. Bardsley and C. R. Vogel, "A Nonnnegatively Constrained Convex 
Programming Method for Image Reconstruction," SIAM Journal on Scientific 
Computing, vol. 25, no. 4, 2004, pp. 1326-1343.

-GPCG, a code developed by More' and Toreldo
-GPNewton, an extension of GPCG to convex problems of my own design.
-Lbfgs-b, a code developed by Nocedal, et. al.
-Knitro, a code developed by Nocedal, et. al.

To run simulations, first start up MatLab. Then do the following

>> startup

For the toeplitz case:
>> load StarData_toep_psf073_128.mat

For the circulant case:
>> load StarData_circ_psf073_128.mat

This gives us a structure array called Data. To view the enclosed
true image, which is a star field obtained off of the web, type

>> imagesc(Data.object), colorbar

The PSF used as the blurring operator was given to use by
Brent Elloerbrock at the Maui center. To view it type

>> imagesc(Data.BTTB_kernel), colorbar

To get a closer view type

>> imagesc(Data.BTTB_kernel(96:160,96:160)), colorbar

We generate the data via the setup_toeplitz.m (go to the bottom of this
document) function found in the Toeplitz directory. We first convolve
the PSF with the true image and then add noise as is described in the
paper. The noisy data can then be view by typing

>> imagesc(Data.noisy_data), colorbar

At this point, we pretend that we don't know the true image and attempt
to reconstruct it, only having the PSF, the noisy image and the noise
model. Depending on the noise model used, we use different algorithms.
For the purely Gaussian noise model we use GPCG. For the purely
Poisson model, which is an approximation of a mixed Poisson/Gaussian
model, we use GPNewton and Lbfgsb.

To run GPCG for the least squares model type

>> Min_wls

or, for circulant data, run the optimized (in terms of ffts) code

>> Min_ls_circulant

To run the projected gradient algorithm type

>> Min_pg

To run the projected Newton method type

>> Min_pn

To run GPNewton type

>> Min_poisson

To run Lbfgs-b type

>> Lbfgsb_poiss

To run EM type

>> EM

Note: This will only work on a SUN computer, since the mex interface is
set up for that.

Note: For some reason, Knitro is not working at this point (11/02).

For each of the above algorithms, the reconstructed image is displayed
along with various convergence data.

%-----------------------------------------------------------------------
%  Data generation.
%-----------------------------------------------------------------------

Instead of loading the above data file we can generate or own data. The
above files simply allow for a benchmark when running comparisons and
ata_toep_psf073_128.mat was the data used for the paper. To generate the
data we do as follows:

The PSF is interpolated from psf073, which is one of four PSFs in
AOpsfs.mat located in the Mat_files directory, using psf_interp.m,
located in the Functions directory. We do this as follows:

>> load AOpsfs

For Toeplitz case:
>> psf = psf_interp(psf_interp(psf073));

For circulant case:
>> psf = psf_interp(psf073);

For a less delta-like PSF try psf023.
Then, to generate the structure array Data, we type

>> load star_cluster

For Toeplitz case:
>> Data = setup_toeplitz(psf,f_true);

For circulant case:
>> Data = setup_circulant(psf,f_true);

The data file star_cluster.mat is in the Mat_files directory, while
setup_toeplitz.m and setup circulant.m are in the Toeplitz and
Circulant directories respectively.

If instead of the star field you want satellite data, replace

>> load star_cluster

above by

>> Gen_data

with nx = 128.
