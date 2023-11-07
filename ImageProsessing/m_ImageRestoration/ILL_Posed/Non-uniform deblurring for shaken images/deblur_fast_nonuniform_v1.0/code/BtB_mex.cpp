/*
    Function to apply a (uniform or non-uniform) blur kernel to an image

    Author:     Oliver Whyte <oliver.whyte@ens.fr>
    Date:       November 2011
    Copyright:  2011, Oliver Whyte
    Reference:  O. Whyte, J. Sivic and A. Zisserman. ``Deblurring Shaken and Partially Saturated Images''. In Proc. CPCV Workshop at ICCV, 2011.
    URL:        http://www.di.ens.fr/willow/research/saturation/
*/

#include <mex.h>
#include <stdlib.h>
#include <math.h>
#include "matrix.h"
#include "ow_mat3.h"
#include "ow_homography.h"

#ifdef __USEOPENMP__
#include <omp.h>
#endif

#define thetax(k) (theta_list[(k)*3])
#define thetay(k) (theta_list[(k)*3+1])
#define thetaz(k) (theta_list[(k)*3+2])

inline double round(double v)
{
	return floor(v + 0.5);
}

inline double max(double const a, double const b) {
	return (a > b) ? a : b;
}

// #define __USEBLAS__

#ifdef __USEBLAS__
#include "blas.h"
double one_d = 1.0;
ptrdiff_t inc = 1;
char uplo[] = "U";
char trans[] = "N"; // transpose matrix? = N or T
#else
inline double dotproduct(double const* x1, double const* x2, int const n) {
	double r = 0;
	for(int i=0; i<n; ++i)
		r += x1[i]*x2[i];
	return r;
}

inline void addselfouterproduct(double const* x, int const n_kernel, double* Q) {
	double p;
	for(int k1=0; k1<n_kernel; ++k1) {
	    if(x[k1]==0)
            continue;
		for(int k2=0; k2<=k1; ++k2) {
            if(x[k2]==0)
                continue;
			p = x[k1]*x[k2];
			Q[k1*n_kernel+k2] += p;
			if(k2!=k1)
				Q[k2*n_kernel+k1] += p;
		}
	}
}

inline void addscaledvector(double const* x, double const s, int const n_kernel, double* q) {
	for(int k=0; k<n_kernel; ++k) {
        if (x[k]==0)
            continue;
		q[k] += x[k]*s;
	}
}
#endif

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	mxArray const* p_ptr = prhs[0]; /* original / sharp image */
	mxArray const* g_ptr = prhs[1]; /* warped / blurry image */
	mxArray const* M_ptr = prhs[2]; /* mask of reliably observed pixels */
	mxArray const* Ksharp_ptr = prhs[3]; /* Intrinsic calibration of original / sharp image */
	mxArray const* Kblurry_ptr = prhs[4]; /* intrinsic calibration of warped / blurry image */
	mxArray const* theta_list_ptr = prhs[5]; /* angles covered by camera kernel */
	bool const non_uniform = 0 != mxGetScalar(prhs[6]); /* Non-uniform blur model? */

	mwSize const n_kernel = (int)mxGetN(theta_list_ptr);
	mwSize const n_kernel2 = n_kernel*n_kernel;
	
	double const *p = mxGetPr(p_ptr);
	double *g = mxGetPr(g_ptr);
	bool const *M = mxGetLogicals(M_ptr);
	double const *Ksharp = mxGetPr(Ksharp_ptr);
	double const *Kblurry = mxGetPr(Kblurry_ptr);
	double *theta_list = mxGetPr(theta_list_ptr);

	mwSize const numdims = mxGetNumberOfDimensions(p_ptr);
	mwSize const *dims_sharp = mxGetDimensions(p_ptr);
	mwSize const h_sharp = dims_sharp[0];
	mwSize const w_sharp = dims_sharp[1];
	mwSize const channels = (numdims==3) ? dims_sharp[2] : 1;

	mwSize const *dims_blurry = mxGetDimensions(g_ptr);
	mwSize const h_blurry = dims_blurry[0];
	mwSize const w_blurry = dims_blurry[1];

	mwSize const n_sharp = h_sharp*w_sharp;
	mwSize const n_blurry = h_blurry*w_blurry;
	mwSize const np = h_sharp*w_sharp*channels;

	mwSize* chan_offset_sharp = new mwSize[channels];
	mwSize* chan_offset_blurry = new mwSize[channels];
	mwSize* chan_offset_kernel = new mwSize[channels];
	for(int c=0; c<channels; ++c) {
		chan_offset_sharp[c] = c*n_sharp;
		chan_offset_blurry[c] = c*n_blurry;
        chan_offset_kernel[c] = c*n_kernel;
	}

	double invKblurry[9];
	inv3(Kblurry,invKblurry);

	/* Check thetas */
	if(!non_uniform) {
		for(int k=0; k<n_kernel; ++k) {
			if(fabs(round(thetay(k))-thetay(k)) > 1e-5 || fabs(round(thetax(k))-thetax(k)) > 1e-5)
				mexErrMsgTxt("theta not integral for uniform blur");
			thetax(k) = round(thetax(k));
			thetay(k) = round(thetay(k));
		}
	}
	
	#if defined(__USEBLAS__)
    ptrdiff_t n_kernel_blas = (ptrdiff_t)n_kernel;
    ptrdiff_t n_kernel2_blas = (ptrdiff_t)(n_kernel2);
    ptrdiff_t channels_blas = (ptrdiff_t)channels;
    ptrdiff_t n_blurry_blas = (ptrdiff_t)n_blurry;
    #endif

	/* Calculate BtB and Btg, fixed during optimization */

	mwSize BtBdims[2] = {n_kernel,n_kernel};
	mxArray* BtB_ptr = mxCreateNumericArray(2, BtBdims, mxDOUBLE_CLASS, mxREAL);
	double* BtB = mxGetPr(BtB_ptr);
	mxArray* Btg_ptr = mxCreateDoubleMatrix(n_kernel, 1, mxREAL); /* mxCreateNumericArray(1, &n_kernel, mxDOUBLE_CLASS, mxREAL); */
	double* Btg = mxGetPr(Btg_ptr);
	/* mxArray* Bt1_ptr = mxCreateDoubleMatrix(n_kernel, 1, mxREAL); */ /* mxCreateNumericArray(1, &n_kernel, mxDOUBLE_CLASS, mxREAL); */
	/* double* Bt1 = mxGetPr(Bt1_ptr); */

	/* Hcache, used to cache homography matrices */
	mxArray* Hcache_ptr = mxCreateDoubleMatrix(9, n_kernel, mxREAL);
	double* Hcache = mxGetPr(Hcache_ptr);
	/* Loop over all orientations k */
	if (non_uniform) {
		/* Calculate homographies and cache them */
		for(int k=0; k<n_kernel; ++k) {
			compute_homography_matrix(Ksharp, &theta_list[k*3], invKblurry, &Hcache[k*9]);
/* 			calculate_homography(&theta_list[k*3],invKblurry,Ksharp,&Hcache[k*9]); */
		}
	}

	/* Storage for one row of B */
//	mxArray* Bi_ptr = mxCreateDoubleMatrix(n_kernel, channels, mxREAL);
    double *Bi, *BtBlocal, *Btglocal;// = mxGetPr(Bi_ptr);

    int xi, yi;
	/* Loop over all warped image pixels:
	yi/xi: 1-based row/column indices into warped image */
	if(non_uniform) {
    #pragma omp parallel shared(M,p,g,Hcache,chan_offset_kernel,chan_offset_sharp,BtB,Btg) private(xi,yi,Bi,BtBlocal,Btglocal)
    {
        Bi       = (double*)calloc(n_kernel*channels, sizeof(double));// new double[n_kernel*channels];
        BtBlocal = (double*)calloc(n_kernel*n_kernel, sizeof(double));// new double[n_kernel*n_kernel];
        Btglocal = (double*)calloc(n_kernel         , sizeof(double));// new double[n_kernel];
        #pragma omp for
		for(xi=1; xi<=w_blurry; ++xi) {
			for(yi=1; yi<=h_blurry; ++yi) {
            	double xj, yj;
            	int xjfloor, yjfloor;
            	double coeffs[4];
				/* i: 0-based linear index into warped image
				= sub2ind([h_blurry w_blurry],yi,xi) -1; */
				int i = (int)((xi-1)*h_blurry + yi - 1);
				if(!M[i])
					continue;
				for(int k=0; k<n_kernel; ++k) {
					/* Project warped image pixel (xxwarp[xi],yywarp[yi]) into original image.
					Position in original image is (xj,yj) */
					project_blurry_to_sharp(yi, xi, &Hcache[k*9], &xj, &yj);
					/* Check if (xj,yj) lies outside domain of original image */
					if (yj<1 || yj>=h_sharp || xj<1 || xj>=w_sharp) {
						for(int c=0; c<channels; ++c)
							Bi[k+chan_offset_kernel[c]] = 0;
					} else {
						interp_coeffs(xj, yj, &xjfloor, &yjfloor, coeffs);
						/* j: 0-based linear index into original image */
						int j = (int)((xjfloor-1)*h_sharp + yjfloor - 1);
						/* Do interpolation */
						for(int c=0; c<channels; ++c) {
                            Bi[k+chan_offset_kernel[c]] = 0;
                            if(p[j          +chan_offset_sharp[c]]!=0) Bi[k+chan_offset_kernel[c]] += coeffs[0]*p[j          +chan_offset_sharp[c]];
                            if(p[j        +1+chan_offset_sharp[c]]!=0) Bi[k+chan_offset_kernel[c]] += coeffs[1]*p[j        +1+chan_offset_sharp[c]];
                            if(p[j+h_sharp  +chan_offset_sharp[c]]!=0) Bi[k+chan_offset_kernel[c]] += coeffs[2]*p[j+h_sharp  +chan_offset_sharp[c]];
                            if(p[j+h_sharp+1+chan_offset_sharp[c]]!=0) Bi[k+chan_offset_kernel[c]] += coeffs[3]*p[j+h_sharp+1+chan_offset_sharp[c]];
						}
					}
				}
				/* Add the outer products for each channel to BtB & Btg */
				for(int c=0; c<channels; ++c) {
    #ifdef __USEBLAS__
                    dsyr_(uplo,&n_kernel_blas,&one_d,&Bi[chan_offset_kernel[c]],&inc,BtBlocal,&n_kernel_blas);
                    daxpy_(&n_kernel_blas,&g[i+chan_offset_blurry[c]],&Bi[chan_offset_kernel[c]],&inc,Btglocal,&inc);
    #else
					addselfouterproduct(&Bi[chan_offset_kernel[c]],n_kernel,BtBlocal);
					addscaledvector(&Bi[chan_offset_kernel[c]],g[i+chan_offset_blurry[c]],n_kernel,Btglocal);
/*                  addscaledvector(&Bi[chan_offset_kernel[c]], 1 ,n_kernel,Bt1); */
    #endif
				}
			}
		}
		// add each thread's local copy to the main copy
		#pragma omp critical
		{
    #ifdef __USEBLAS__
            daxpy_(&n_kernel_blas,&one_d,Btglocal,&inc,Btg,&inc);
            daxpy_(&n_kernel2_blas,&one_d,BtBlocal,&inc,BtB,&inc);
    #else
            addscaledvector(Btglocal,1.0,n_kernel,Btg);
            addscaledvector(BtBlocal,1.0,n_kernel2,BtB);
    #endif
		}
        free(Bi);//delete [] Bi;
        free(BtBlocal);//delete [] BtBlocal;
        free(Btglocal);//delete [] Btglocal;
	}
	} else {
		for(int xi=1; xi<=w_blurry; ++xi) {
			for(int yi=1; yi<=h_blurry; ++yi) {
				/* i: 0-based linear index into warped image
				= sub2ind([h_blurry w_blurry],yi,xi); */
				int i = (int)((xi-1)*h_blurry + yi - 1);
				if(!M[i])
					continue;
				for(int k=0; k<n_kernel; ++k) {
					int xj = xi + (int)round(theta_list[k*3  ]);
					int yj = yi + (int)round(theta_list[k*3+1]);
					/* Check if (xj,yj) lies outside domain of original image */
					if (yj<1 || yj>=h_sharp || xj<1 || xj>=w_sharp) {
						for(int c=0; c<channels; ++c)
							Bi[k+chan_offset_kernel[c]] = 0;
					} else {
						/* j: 0-based linear index into original image
						= sub2ind([h_sharp w_sharp],yjfloor,xjfloor); */
						int j = (int)((xj-1)*h_sharp + yj - 1);
						/* Do interpolation */
						for(int c=0; c<channels; ++c)
							Bi[k+chan_offset_kernel[c]] = p[j+chan_offset_sharp[c]];
					}
				}
				/* Add the outer products for each channel to BtB & Btg */
				for(int c=0; c<channels; ++c) {
    #ifdef __USEBLAS__
                    dsyr_(uplo,&n_kernel_blas,&one_d,&Bi[chan_offset_kernel[c]],&inc,BtB,&n_kernel_blas);
                    daxpy_(&n_kernel_blas,&g[i+chan_offset_blurry[c]],&Bi[chan_offset_kernel[c]],&inc,Btg,&inc);
    #else
					addselfouterproduct(&Bi[chan_offset_kernel[c]],n_kernel,BtB);
					addscaledvector(&Bi[chan_offset_kernel[c]],g[i+chan_offset_blurry[c]],n_kernel,Btg);
/*                  addscaledvector(&Bi[chan_offset_kernel[c]], 1 ,n_kernel,Bt1); */
    #endif
				}
			}
		}
	}

#if defined(__USEBLAS__)
    // Need to copy from upper half to lower half of matrix
	for(int k1=0; k1<n_kernel; ++k1) {
		for(int k2=0; k2<k1; ++k2) {
            BtB[k2*n_kernel+k1] = BtB[k1*n_kernel+k2];
		}
	}
#endif
	
	plhs[0] = BtB_ptr;
	plhs[1] = Btg_ptr;
/*  plhs[2] = Bt1_ptr; */

	delete[] chan_offset_sharp;
	delete[] chan_offset_blurry;
	delete[] chan_offset_kernel;
}


