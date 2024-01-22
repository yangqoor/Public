Title:      Matlab Code for Fast Blind Removal of Non-Uniform Camera Shake Blur
Author:     Oliver Whyte <oawhyte@gmail.com>
Version:    1.0
Date:       Sept 17, 2014
Copyright:  2012, Oliver Whyte
URL:        http://www.di.ens.fr/willow/research/deblurring/, 
            http://www.di.ens.fr/willow/research/saturation/

Matlab Code for Fast Blind Removal of Non-Uniform Camera Shake Blur
===================================================================

This package contains code to perform fast blind deblurring of images degraded 
by camera shake, using the MAP algorithm described in our IJCV 2012 paper 
[][#Whyte12], and the fast approximation of spatially-varying blur described in 
our CPCV 2011 paper [][#Whyte11]. Please cite these papers if using this code 
in an academic publication.

Please send bug reports to <oawhyte@gmail.com>

[#Whyte11]: O. Whyte, J. Sivic, and A. Zisserman. "Deblurring Shaken and
Partially Saturated Images". In Proc. CPCV Workshop, with ICCV, 2011.

[#Whyte12]: O. Whyte, J. Sivic, A. Zisserman, and J. Ponce. "Non-uniform 
Deblurring for Shaken Images". IJCV, 2011 (accepted).

## 1 Acknowledgements ##

This package includes modified versions of code published by several other authors:

* Sparse Deconvolution code of Levin et al. Downloaded from <http://groups.csail.mit.edu/graphics/CodedAperture/DeconvolutionCode.html>
* Fast Deconvolution code of Krishnan and Fergus. Downloaded from <http://cs.nyu.edu/~dilip/research/fast-deconvolution/>
* FFT-based Poisson image blending by Amit Agrawal. Downloaded May 2008 from <http://www.umiacs.umd.edu/~aagrawal/ICCV2007Course/PseudoCode.PDF>
* Shock-filter code of Guy Gilboa. Downloaded from <http://visl.technion.ac.il/~gilboa/PDE-filt/shock.m>
* LARS-LASSO code of Karl Skoglund. Most recent version available at <http://www.imm.dtu.dk/projects/spasm/>


## 2 Installing & Running ##

* Add the `code` directory to your Matlab path, e.g. with `addpath(fullfile(pwd,'code'))`
* Pre-compiled mex files are included for several platforms. However, if necessary,
  compile the included mex files by running `blind_mexall.m`
    * On Windows, you will probably need to edit blind_mexall.m to disable openmp
      and blas
* Run one of the included examples, e.g. `run examples/deblur_garden.m` to try 
  out the code

### 2.1 Compatibility ###

Tested on:

* 64-bit Linux Ubuntu 10.04 with Matlab R2011a
* 64-bit Mac OS X 10.6 with Matlab R2010a
* 64-bit Windows 8.1 with Matlab R2011b


## 3 License ##

Copyright (c) 2012, Oliver Whyte

Permission is hereby granted, free of charge, to any person obtaining a copy of 
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do 
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
SOFTWARE.


## 4 Changelog ##

### Version 1.0 (17-Sep-2014) ###

- Initial public release
