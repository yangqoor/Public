% poisson_blend_backslash
% 
% Perform gradient domain blending (Poisson blending) using Matlab backslash operator to solve Poisson equation, in order to fill a region of an image.
% 
% imout = poisson_blend_backslash(gx,gy,im,mask,mask2)
% 
% Inputs -------------------------------------------------------
%    gx:    height x width x num_channels x-component of gradient field to use inside target region. gx(i,j) gives desired value for im(i,j+1) - im(i,j)
%    gy:    height x width x num_channels y-component of gradient field to use inside target region. gy(i,j) gives desired value for im(i+1,j) - im(i,j)
%    im:    height x width x num_channels image values to be used outside target region
%    mask:  height x width x 1 binary mask of target region. 0: use [gx,gy], 1: use im
%    mask2: height x width x 1 binary mask of pixels for which the image generating gx and gy was valid. 1: valid, 0: not valid
% 
% Outputs ------------------------------------------------------
%    imout: height x width x num_channels image of result
% 

%	Author:		Oliver Whyte <oliver.whyte@ens.fr>
%	Date:		November 2011
%	Copyright:	2011, Oliver Whyte
%	Reference:  O. Whyte, J. Sivic and A. Zisserman. ``Deblurring Shaken and Partially Saturated Images''. In Proc. CPCV Workshop at ICCV, 2011.
%	URL:		http://www.di.ens.fr/willow/research/saturation/

function imout = poisson_blend_backslash(gx,gy,im,mask,mask2)
if nargin < 5, mask2 = true(size(mask)); end
if nargin < 6, wholeimage = false; end
imout = im;
[hei, wid, channels] = size(im);
N = [0 1 0;1 0 1;0 1 0];
solvemask = ~(~mask & mask2);
im_ndx = find(~solvemask);
[mr,mc] = ind2sub([hei wid],im_ndx);
mr = min(mr):max(mr);
mc = min(mc):max(mc);
n = length(im_ndx);
vec_ndx = (1:n)';
% cardinal_N = filter2(N,ones(hei,wid),'same');
cardinal_N = filter2(N,double(mask2),'same');
cardinal_N = cardinal_N(im_ndx);

vec_ndx_map = zeros(hei,wid);
vec_ndx_map(im_ndx) = vec_ndx;

% for each pixel we need to find out which of its neighbours are also
% inside the region to be solved
% 0 means its neighbour on that side is outside the region being solved
tmp = filter2([1;0;0],vec_ndx_map,'same');
above = tmp(im_ndx);
tmp = filter2([0;0;1],vec_ndx_map,'same');
below = tmp(im_ndx);
tmp = filter2([1 0 0],vec_ndx_map,'same');
left = tmp(im_ndx);
tmp = filter2([0 0 1],vec_ndx_map,'same');
right = tmp(im_ndx);

A_inds = [[vec_ndx,vec_ndx,cardinal_N];...
          [vec_ndx(above>0),above(above>0),-ones(nnz(above),1)];...
          [vec_ndx(below>0),below(below>0),-ones(nnz(below),1)];...
          [vec_ndx(left >0), left(left >0),-ones(nnz(left ),1)];...
          [vec_ndx(right>0),right(right>0),-ones(nnz(right),1)]];
A = sparse(A_inds(:,1),A_inds(:,2),A_inds(:,3),n,n);

m2x = [mask(:,2:wid) zeros(hei,1)] - mask;
m2y = [mask(2:hei,:);zeros(1,wid)] - mask;


for chan=1:channels
    imtmp = im(:,:,chan).*mask;
    constraint = filter2(N,imtmp.*mask2,'same');
    tmpx = gx(:,:,chan).*mask2;
    tmpx(m2x==-1) = 0; % set to zero those gradients whose calculation involves pixels outside the known region
    tmpy = gy(:,:,chan).*mask2;
    tmpy(m2y==-1) = 0;
    lx = filter2([-1 1 0],tmpx,'same');
    ly = filter2([-1;1;0],tmpy,'same');
    laplacian = lx + ly;
    b = -laplacian(im_ndx) + constraint(im_ndx);

    f = A\b;

    % fill in solution
    imtmp(im_ndx) = f;
    imout(:,:,chan) = imtmp;
end
