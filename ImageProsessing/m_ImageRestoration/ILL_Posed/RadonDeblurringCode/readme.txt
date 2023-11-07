% August 18 2010
% Taeg Sang Cho

===========================================================================
PLEASE DO NOT REDISTRIBUTE THIS CODE.  THIS CODE SHOULD ONLY BE USED FOR RESEARCH PURPOSES.
===========================================================================

This ZIP file contains code and data for the algorithm presented in Chapter 2 of my thesis: "Removing motion blur from photographs".

demo.m contains a script for running the demo code.  The code is commented, so it should be self explanatory.  

Parameters are optimized for an unscaled raw image (see one of the examples in testData_web).

The current implementation of the RadonMAP algorithm requires quite a bit of memory.  To solve for a 1 mega pixel image, we need about 3-4GB of RAM memory.  

Acknowledgments

Our implementation modifies the deblurring code of Joshi et al. CVPR 2008.  We would like to thank the authors for making the code available.

We use an implementation of "Fast Image Deconvolution using Hyper-Laplacian Priors" by Dilip Krishnan.  http://cs.nyu.edu/~dilip/wordpress/code/fastdeconv.tgz
