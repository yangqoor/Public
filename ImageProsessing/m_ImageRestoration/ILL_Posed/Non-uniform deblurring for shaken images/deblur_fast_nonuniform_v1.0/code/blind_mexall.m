% Author:     Oliver Whyte <oliver.whyte@ens.fr>
% Date:       January 2012
% Copyright:  2012, Oliver Whyte
% Reference:  O. Whyte, J. Sivic, A. Zisserman, and J. Ponce. "Non-uniform Deblurring for Shaken Images". IJCV, 2011 (accepted).
%             O. Whyte, J. Sivic and A. Zisserman. "Deblurring Shaken and Partially Saturated Images". In Proc. CPCV Workshop at ICCV, 2011.
% URL:        http://www.di.ens.fr/willow/research/deblurring/, http://www.di.ens.fr/willow/research/saturation/

function blind_mexall()

% Mex files are in the same directory as this m-file
code_dir = fileparts(mfilename('fullpath'));

mexcmd = sprintf('mex -largeArrayDims -outdir %s ',code_dir);
ompflags = [];
blasflags = [];

% Optional -- use openmp (multi-threading), and blas (matrix operations) for fastest performance
openmp = true;
blas = true;

if openmp
    ompflags = ' -D__USEOPENMP__ ';
    if isunix
        ompflags = [ompflags ' CXXFLAGS=''\$CXXFLAGS -fopenmp'' LDFLAGS=''\$LDFLAGS -fopenmp'' '];
    else
        ompflags = [ompflags ' COMPFLAGS="/openmp $COMPFLAGS" '];
    end
end
if blas
    blasflags = ' -D__USEBLAS__ -lblas ';
end

eval(sprintf('%s %s/BtB_mex.cpp %s %s',               mexcmd,code_dir,blasflags,ompflags));
eval(sprintf('%s %s/apply_blur_kernel_mex.cpp',       mexcmd,code_dir));
eval(sprintf('%s %s/make_kernel_psf_jacobian_mex.cpp',mexcmd,code_dir));
eval(sprintf('%s %s/apply_homography_image_mex.cpp',  mexcmd,code_dir));
