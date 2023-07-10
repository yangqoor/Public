## SOOT Sparse blind deconvolution Matlab toolbox
## Implements the regularized $\ell_1/\ell_2$ norm ratio restoration from
##
Euclid in a Taxicab: Sparse Blind Deconvolution with Smoothed $\ell_1/\ell_2$ Regularization
IEEE Signal Processing Letters, May 2015
http://dx.doi.org/10.1109/LSP.2014.2362861

## Command line
demo_SOOT_toolbox.m

## History
2015/04/11: version 1.0 
demo_SOOT_toolbox.m

## bibtex file
@Article{Repetti_A_2015_j-ieee-spl_euclid_tsbdsl1l2r,
  Title                    = {Euclid in a Taxicab: Sparse Blind Deconvolution with Smoothed $\ell_1/\ell_2$ Regularization},
  Author                   = {A. Repetti and M. Q. Pham and L. Duval and E. Chouzenoux and J.-C. Pesquet},
  File                     = {Repetti_A_2015_j-ieee-spl_euclid_tsbdsl1l2r.pdf:Repetti_A_2015_j-ieee-spl_euclid_tsbdsl1l2r.pdf:PDF},
  Journal                  = {IEEE Signal Processing Letters},
  Month                    = {May},
  Number                   = {5},
  Pages                    = {539--543},
  Volume                   = {22},
  Year                     = {2015},

  Abstract                 = {The ${ell _1}/{ell _2}$ ratio regularization function has shown good performance for retrieving sparse signals in a number of recent works, in the context of blind deconvolution. Indeed, it benefits from a scale invariance property much desirable in the blind context. However, the ${ell _1}/{ell _2}$ function raises some difficulties when solving the nonconvex and nonsmooth minimization problems resulting from the use of such a penalty term in current restoration methods. In this paper, we propose a new penalty based on a smooth approximation to the ${ell _1}/{ell _2}$ function. In addition, we develop a proximal-based algorithm to solve variational problems involving this function and we derive theoretical convergence results. We demonstrate the effectiveness of our method through a comparison with a recent alternating optimization strategy dealing with the exact ${ell _1}/{ell _2}$ term, on an application to seismic data blind deconvolution.},

  Doi                      = {10.1109/LSP.2014.2362861},
  Eprint                   = {1407.5465},
  Oai2identifier           = {1407.5465},
  Owner                    = {duvall},
  Timestamp                = {2015.03.21.00.44},
  Url                      = {http://dx.doi.org/10.1109/LSP.2014.2362861}
}
