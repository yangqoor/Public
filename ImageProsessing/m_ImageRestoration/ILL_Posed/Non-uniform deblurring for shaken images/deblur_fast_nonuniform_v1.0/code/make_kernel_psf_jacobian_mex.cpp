/*
    Function to apply a (uniform or non-uniform) blur kernel to an image

    Author:     Oliver Whyte <oliver.whyte@ens.fr>
    Date:       November 2011
    Copyright:  2011, Oliver Whyte
    Reference:  O. Whyte, J. Sivic and A. Zisserman. ``Deblurring Shaken and Partially Saturated Images''. In Proc. CPCV Workshop at ICCV, 2011.
    URL:        http://www.di.ens.fr/willow/research/saturation/
*/

#include <mex.h>
#include <math.h>

#include "ow_homography.h"
#include "ow_sort.h"

inline double round(double v)
{
	return floor(v + 0.5);
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	mxArray const* dims_sharp_ptr = prhs[0]; /* dimensions of original / sharp image */
	mxArray const* Ksharp_ptr = prhs[1]; /* intrinsic calibration of original / sharp image */
	mxArray const* Kblurry_ptr = prhs[2]; /* Intrinsic calibration of warped / blurry image */
	mxArray const* theta_list_ptr = prhs[3]; /* angles covered by camera kernel */
    mxArray const* p0_ptr = prhs[4];

	double const *dims_sharp = mxGetPr(dims_sharp_ptr);
	double const *Ksharp = mxGetPr(Ksharp_ptr);
	double const *Kblurry = mxGetPr(Kblurry_ptr);
	double const *theta_list = mxGetPr(theta_list_ptr);
	double const *p0 = mxGetPr(p0_ptr);

	mwSize const h_sharp = (mwSize const)dims_sharp[0];
	mwSize const w_sharp = (mwSize const)dims_sharp[1];
	mwSize const n_sharp = h_sharp*w_sharp;
	mwSize const n_kernel = mxGetN(theta_list_ptr);
	double const xi0 = p0[0];
	double const yi0 = p0[1];
	
    double const dx0 = 0.0;
    double const dy0 = 0.0;
	
	double invKblurry[9];
	inv3(Kblurry,invKblurry);

    mwSize nzmax = n_kernel*4;
	mxArray *J_ptr = mxCreateSparse(n_sharp,n_kernel,nzmax,mxREAL);
	double *Jnzvals = mxGetPr(J_ptr);
	mwIndex *Jnzrows = mxGetIr(J_ptr);
	mwIndex *Jcolstart = mxGetJc(J_ptr);
	Jcolstart[0] = 0;

	double yj, xj, dx, dy, dyfloor, dxfloor;
	double H[9];
	double R[9];
	double f[4];
    mwIndex xl[4], yl[4], l[4];
	/* Loop over all rotations */
	for(int k=0; k<n_kernel; ++k) {
		compute_homography_matrix(Ksharp, &theta_list[k*3], invKblurry, H);
		Jcolstart[k+1] = Jcolstart[k];
        /* Project blurry pixel into sharp image */
	    project_blurry_to_sharp(yi0, xi0, H, &xj, &yj);
        /* Get offset between pixels */
        dx = xj - xi0 + dx0;
        dy = yj - yi0 + dy0;
		/* If very close to a whole pixel, round to that pixel */
        if(fabs(dx-round(dx)) < 1e-5)   dx = round(dx);
        if(fabs(dy-round(dy)) < 1e-5)   dy = round(dy);
		/* Integer parts of position */
		dyfloor = floor(dy);
		dxfloor = floor(dx);
		/* Bilinear interpolation coefficients */
		f[0] = (1-(dx-dxfloor))*(1-(dy-dyfloor)); /* I(xoi  ,yoi  ) */
		f[1] = (1-(dx-dxfloor))*   (dy-dyfloor) ; /* I(xoi  ,yoi+1) */
		f[2] =    (dx-dxfloor) *(1-(dy-dyfloor)); /* I(xoi+1,yoi  ) */
		f[3] =    (dx-dxfloor) *   (dy-dyfloor) ; /* I(xoi+1,yoi+1) */
        /* Get 2d indices into kernel, with (0,0) in the top left pixel, and negative offsets looping back around at the far edges */
        xl[0] = (dxfloor >= 0) ? dxfloor   : w_sharp+dxfloor;   yl[0] = (dyfloor >= 0) ? dyfloor   : h_sharp+dyfloor;
        xl[1] = xl[0];                                          yl[1] = (dyfloor+1>=0) ? dyfloor+1 : h_sharp+dyfloor+1;
        xl[2] = (dxfloor+1>=0) ? dxfloor+1 : w_sharp+dxfloor+1; yl[2] = yl[0];
        xl[3] = xl[2];                                          yl[3] = yl[1];
        if(xl[0]>=w_sharp || xl[1]>=w_sharp || xl[2]>=w_sharp || xl[3]>=w_sharp)
            mexErrMsgTxt("Entry is outside width of PSF");
        if(yl[0]>=h_sharp || yl[1]>=h_sharp || yl[2]>=h_sharp || yl[3]>=h_sharp)
            mexErrMsgTxt("Entry is outside height of PSF");
		/* l: 0-based linear index into psf */
        l[0] = xl[0]*h_sharp + yl[0];
        l[1] = xl[1]*h_sharp + yl[1];
        l[2] = xl[2]*h_sharp + yl[2];
        l[3] = xl[3]*h_sharp + yl[3];
        if(l[0]>=n_sharp || l[1]>=n_sharp || l[2]>=n_sharp || l[3]>=n_sharp)
            mexErrMsgTxt("Trying to insert an entry into a row that doesn't exist");
		/* For each pixel being sampled from the original image, either insert entry into non-zeros of column k, or add to existing entry which corresponds to that original image pixel */
		for(int op=0; op<4; ++op) {
			if(f[op]==0)
				continue;
            /* Search column for entry for this row */
            mwIndex el=Jcolstart[k];
            while(el<Jcolstart[k+1] && Jnzrows[el]!=l[op])
                ++el;
            /* If we didn't find an entry for this row of the matrix, we add it to the column */
            if(el==Jcolstart[k+1])
            {
                Jnzvals[el] = f[op];
                Jnzrows[el] = l[op];
                Jcolstart[k+1] = el+1;
            }
            else
            { /* Otherwise we add the coefficient to the existing entry */
                Jnzvals[el] += f[op];
            }
			/* If we have exceeded the allocated size, re-allocate arrays */
			if(Jcolstart[k+1] >= nzmax) {
				mwSize nzmaxnew = (mwSize)ceil( ((double)n_kernel) * ((double)nzmax) / ((double)k) );
/* 			           mexPrintf("(Increasing memory allocation from %d to %d non-zeros) ",nzmax,nzmaxnew); */
				nzmax = nzmaxnew;
				mxSetPr(J_ptr,(double*) mxRealloc(Jnzvals, nzmax*sizeof(double)));
				mxSetIr(J_ptr,(mwIndex*) mxRealloc(Jnzrows, nzmax*sizeof(mwIndex)));
				mxSetNzmax(J_ptr, nzmax);
				Jnzvals = mxGetPr(J_ptr);
				Jnzrows = mxGetIr(J_ptr);
			}
		}
	}
	/* Trim A back down to actual number of non-zeros */
	nzmax = Jcolstart[n_kernel];
	mxSetPr(J_ptr,(double*) mxRealloc(Jnzvals, nzmax*sizeof(double)));
	mxSetIr(J_ptr,(mwIndex*) mxRealloc(Jnzrows, nzmax*sizeof(mwIndex)));
	mxSetNzmax(J_ptr, nzmax);
	Jnzvals = mxGetPr(J_ptr);
	Jnzrows = mxGetIr(J_ptr);
	/* Sort entries of each column */
	for(int k=0; k<n_kernel; ++k) {
		quicksort(Jnzrows, Jcolstart[k], Jcolstart[k+1]-1, Jnzvals);
	}
	/* Assign outputs */
	plhs[0] = J_ptr;
}
