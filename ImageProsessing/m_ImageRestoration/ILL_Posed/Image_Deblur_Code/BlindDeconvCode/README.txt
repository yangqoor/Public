This package contains implementations of the MAP_k
blind deconvolution algorithms described in the paper

"Efficient Marginal Likelihood Optimization in Blind Deconvolution" 
Levin, Weiss, Durand and Freeman, CVPR2011

Usage of this code is free for research goals only.
(c) Anat Levin, anat.levin@weizmann.ac.il, March 2011.

-------------------------------------------------------------

Quick start:
The package contains 5 test*.m files which run each of the 5 algorithms 
described in the manuscript, on each of the 32 test images of Levin etal's 
CVPR2009 paper.
There are also 5 deconv* functions which set up a deconvolution problem
which matches each algorithm.
The best  algorithm is free energy with a diagonal covariance approximation, 
in the filters domain (that is, solving for each derivative independently, 
without enforcing integrability). So if you are mostly interested in a 
good blind deconvolution algorithm- start with this one.
Also note that the sampling covariance approximation algorithm is *very* slow.

data directories:
test_data/ - contains the 32 test images
resdir/-     a subset of the results of the 5 test* scripts, as well as 
             Fergus and Cho algorithms. (We could not include all results 
             due to the limits on the size of the supplementary file.)

To read the results and plot error statistics, see the file
read_res.m


----------------
More on the structure of the code:

The attached code is meant to be a general enough to handle several versions 
of MAP_k algorithms.

The main object passed between the functions and carrying the deconvolution
 problem is a struct "prob"
This struct have fields indicating the various algorithmic options, 
as well as the imgs and kernel data. See fields description below.

We have 5 different deconv* functions which set the problem parameters for 
each of the 5 implemented algorithms.
After setting the relevant parameters the function 'multires_deconv' is called.
This function builds a pyramid, downscale and upscale the problem between the 
different layers.
To solve for each layer, it calls deconv1
Deconv1 basically alternate between updating x and updating k, we have several
different functions for updating x and k, depending on the specific algorithm
chosen. 


Data fields:
prob.y- blurred image
prob.k- current kernel estimation
prob.filty -derivatives of blurred image when solving in the filter space
prob.x- current x estimation
prob.filtx- current estimation of x derivatives (when solving in the filter
	    space, that's our actual estimated data)
prob.xcov-  cell of xcov, (if we solve in the filter space, there is a 
            separate covariance for every filter.
            When we assume a diagonal covariance or a frequency diagonal
            covariance, this is a matrix whose size is equal to the size of 
            the image x. When we use the sampling approach we  also compute 
            non diagonal elements, so this is a sparse NxN matrix.
prob.freeeng- the free energy at every iteration, useful as a sanity check 
            that we are doing things right- the free energy should decrease 
            from iteration to iteration. however, note that since in practice 
            we change the noise variance in each iteration, we ruin the 
            expected decrease. Also, to ensure proper decrease we should use 
            the x from the previous iteration and not initialize in every 
            iter (see prob.init_x_every_itr  below)


Algorithmic option fields:
prob.prior_pi, prob.prior_ivar- MOG prior parameters- weights and inverse 
      variance of each mixture component 
prob.filts- the filters on which the prior is placed. Our default are 
            the simple derivatives [-1 1], [-1 1]^T, but more sophisticated
            filters can be used.
prob.cycconv- do we assume the convolution is cyclic? in most cases not. 
              (relevant only for the frequency deconvolution case).
prob.covtype- the type of covariance matrix approximation- 
              can be 'diag', 'freqdiag' or 'smp'   
prob.update_x- how do we solve for x- 'conjgrad' solver or 'freqdeconv';
prob.filt_space- do we represent the problem in the filter (derivatives) 
              space or in the image space. that is do we actually solve for
              the image, or just for an independent set of derivatives, 
              without enforcing integrability.
prob.init_x_every_itr- do we initialize x in every update x iteration, and 
              start the iterative reweighted least squares from scratch, or
              do we use the solution from the previous iteration. We noticed 
              that the convergence is better when we initialize every iteration. 
              However, to ensure that the free energy is perfectly decreasing 
              from iteration to iteration, we actually need to continue from 
              the previous solution.
prob.k_prior_ivar-regularization weight when solving for the kernel 
prob.cycconv- do we assume the convolution is cyclic? in most cases not. 
            (relevant only for the frequency deconvolution case).