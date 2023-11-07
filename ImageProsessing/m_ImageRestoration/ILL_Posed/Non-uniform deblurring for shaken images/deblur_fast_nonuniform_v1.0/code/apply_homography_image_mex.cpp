/************************************************************************
 * im, H, rows2c1, cols2c1, bgout  *
 *                                                                      *
 ************************************************************************/

#include <mex.h>
#include <stdlib.h>
#include <math.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (nrhs != 5 && nrhs != 6)
        mexErrMsgTxt("apply_homography_image_mex must have 5 or 6 arguments");
    
    mxArray const* im1_ptr = prhs[0];
    mxArray const* hom_ptr = prhs[1];
    mxArray const* row_ptr = prhs[2];
    mxArray const* col_ptr = prhs[3];
    mxArray const* bgd_ptr = prhs[4];
    bool const onesided = (nrhs>5) ? (bool)mxGetScalar(prhs[5]) : false;
    
    if (!mxIsDouble(im1_ptr))
        mexErrMsgTxt("apply_homography_image_mex takes only double arguments for im1");
    if (!mxIsDouble(hom_ptr))
        mexErrMsgTxt("apply_homography_image_mex takes only double arguments for homography");
    if (nlhs > 1)
        mexErrMsgTxt("Must have exactly one output.");
    
    mwSize const *imdims = mxGetDimensions(im1_ptr);
    mwSize hei = imdims[0];
    mwSize wid = imdims[1];
    mwSize channels = (mxGetNumberOfDimensions(im1_ptr)==3) ? imdims[2] : 1;
    
    double const* im1 = mxGetPr(im1_ptr);
    double const* H   = mxGetPr(hom_ptr);
    double const* rowsout = mxGetPr(row_ptr);
    double const* colsout = mxGetPr(col_ptr);
    double const bg = mxGetScalar(bgd_ptr);
    
    mwSize heiout = (mxGetNumberOfDimensions(row_ptr)==1) ? mxGetM(row_ptr) : ( (mxGetM(row_ptr) > mxGetN(row_ptr)) ? mxGetM(row_ptr) : mxGetN(row_ptr) );
    mwSize widout = (mxGetNumberOfDimensions(col_ptr)==1) ? mxGetM(col_ptr) : ( (mxGetM(col_ptr) > mxGetN(col_ptr)) ? mxGetM(col_ptr) : mxGetN(col_ptr) );
    
    // make output array
    mwSize outdims[3] = {heiout,widout,channels};
    mxArray* im2_ptr = mxCreateNumericArray(3, outdims, mxDOUBLE_CLASS, mxREAL);
    double* im2 = mxGetPr(im2_ptr);
    
#define get(A,r,c,H,W) ((A)[(c)*(H) + (r)])
#define get3(A,r,c,k,H,W,L) ((A)[(r)+(c)*(H)+(k)*(W)*(H)])
#define getI1(r,c,k) get3(im1,r,c,k,hei,wid,channels)
#define getI2(r,c,k) get3(im2,r,c,k,heiout,widout,channels)
    
#define eps (1e-16)

    double denom, i2, j2, f1, f2, f3, f4;
    int i2i, j2i;
    for(int i=0; i < heiout; ++i) {
        for(int j=0; j < widout; ++j) {
            // Get comparison patch by bilinear interpolation
            denom = (H[2]*colsout[j] + H[5]*rowsout[i] + H[8]);
            i2 = (H[1]*colsout[j] + H[4]*rowsout[i] + H[7])/(denom+eps) - 1;
//             Hy(H,colsout[j],rowsout[i]) - 1;
            j2 = (H[0]*colsout[j] + H[3]*rowsout[i] + H[6])/(denom+eps) - 1;
//             Hx(H,colsout[j],rowsout[i]) - 1;
            if((onesided && denom<0) || i2<0 || i2>=hei-1 || j2<0 || j2>=wid-1) {
                for(int k=0; k<channels; ++k) {
                    getI2(i,j,k) = bg;
                }
            } else {
                i2i = (int)floor(i2);
                j2i = (int)floor(j2);
                f1 = (1-(i2-i2i))*(1-(j2-j2i));
                f2 =    (i2-i2i) *(1-(j2-j2i));
                f3 = (1-(i2-i2i))*   (j2-j2i) ;
                f4 =    (i2-i2i) *   (j2-j2i) ;
                for(int k=0; k<channels; ++k)
                  getI2(i,j,k) = f1*getI1(i2i,  j2i  ,k) + f2*getI1(i2i+1,j2i  ,k) + f3*getI1(i2i,  j2i+1,k) + f4*getI1(i2i+1,j2i+1,k);
            }
        }
    }
    
    // assign output array
    plhs[0] = im2_ptr;
}

