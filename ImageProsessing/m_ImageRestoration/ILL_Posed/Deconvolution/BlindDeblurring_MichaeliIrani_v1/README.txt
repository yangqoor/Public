
==============================================================================================

This code implements the algorithm described in the paper:
  "Blind deblurring using internal patch recurrence"
           by Tomer Michaeli and Michal Irani

For a blurry image y, related to a sharp image x through convolution with a blur kernel H,
the algorithm estimates the kernel H and also outputs a latent sharp image corresponding to x.
It is recommended not to use the latent sharp image as the final deblurred output. Rather,
to obtain a deblurred version of the input image, it is recommended to use the estimated
kernel H within a good nonblind deblurring method (such as the EPLL method by Zoran & Weiss). 

==============================================================================================

For the nearest neighbor search, our code uses the TreeCANN algorithm by Igor Olonetsky and 
Shai Avidan, which is included in this zip file for convenience. To install this package, 
please follow the instructions in the file readme.txt under the directory TreeCANN_code_20121022.
It is recommended to use the version we supply here rather than the one on the authors' websites
as it includes a bug fix.

To perform nonblind deblurring with the estimated kernel, please download the EPLL code from
the website of one of the authors (Daniel Zoran & Yair Weiss).

==============================================================================================

To run the nonblind deblurring algorithm, make sure that the directory and all of its sub-directories
are included in the Matlab path. Then use:

    [H, img_deblurred] = BlindDeblurring_MichaeliIrani_v1(img, KernelSize)

img should be a grayscale image with double precision values in the range [0,255]
(if it has a different format, then it is converted into this format).

KernelSize is an odd number specifying the width of the (square) kernel
(if it is not odd, it is modified to be odd).

H is the estimated kernel corresponding to correlation (namely filter2) and not convolution
(like conv2). To turn in into a convolution kernel (to be used, for example, in the EPLL
nonblind deblurring method), use H = rot90(H,2).

img_deblurred is the latent sharp image. It is usually not of sufficient visual quality.
To obtain the final deblurred image, please use a good nonblind deblurring method (like EPLL)
with the estimated kernel H.

==============================================================================================

   CITATION
   
If you use this code in a scientific project, you should cite the following paper in any
resulting publication:

  Tomer Michaeli and Michal Irani, "Blind deblurring using internal patch recurrence", ECCV, 2012.

==============================================================================================
