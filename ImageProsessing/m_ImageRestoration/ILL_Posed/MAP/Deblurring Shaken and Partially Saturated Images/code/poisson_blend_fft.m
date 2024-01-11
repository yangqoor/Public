% poisson_blend_fft
% 
% Recover an image from a gradient field, with Dirichlet boundary conditions
% 
% poisson_blend_fft(gx,gy,boundary_image)
% 
% Inputs -------------------------------------------------------
%    gx:             height x width x num_channels x-component of gradient field
%    gy:             height x width x num_channels y-component of gradient field
%    boundary_image: height x width x num_channels array of boundary conditions
% 
% Outputs ------------------------------------------------------
%    img_direct:     height x width x num_channels recovered image
% 
% Original Code by Amit Agrawal, downloaded from
% http://www.umiacs.umd.edu/~aagrawal/ICCV2007Course/PseudoCode.PDF on 20/05/2008
% Modified by Oliver Whyte, 2010
function [img_direct] = poisson_blend_fft(gx,gy,boundary_image)
% if only one input, assume left half is gx, right half is gy
if nargin < 2, gy = gx(:,end/2+1:end,:); gx = gx(:,1:end/2,:); end
if nargin < 3, boundary_image = zeros(size(gx)); end
[H,W,C] = size(boundary_image);
img_direct = boundary_image;
for c=1:C
	gxx = zeros(H,W);
	gyy = zeros(H,W);
	j = 1:H-1;
	k = 1:W-1;
	% Laplacian
	gyy(j+1,k) = gy(j+1,k,c) - gy(j,k,c);
	gxx(j,k+1) = gx(j,k+1,c) - gx(j,k,c);
	f = gxx + gyy;
	% boundary image contains image intensities at boundaries
	boundary_image(2:end-1,2:end-1,c) = 0;
	j = 2:H-1;
	k = 2:W-1;
	f_bp = zeros(H,W);
	f_bp(j,k) = -4*boundary_image(j,k,c) + boundary_image(j,k+1,c) + boundary_image(j,k-1,c) + boundary_image(j-1,k,c) + boundary_image(j+1,k,c);
	f1 = f - f_bp;% subtract boundary points contribution
	% DST Sine Transform algo starts here
	f2 = f1(2:end-1,2:end-1);
	%compute sine transform
	tt = dst(f2);
	f2sin = dst(tt')';
	%compute Eigen Values
	[x,y] = meshgrid(1:W-2,1:H-2);
	denom = (2*cos(pi*x/(W-1))-2) + (2*cos(pi*y/(H-1)) - 2) ;
	%divide
	f3 = f2sin./denom;
	%compute Inverse Sine Transform
	tt = idst(f3);
	img_tt = idst(tt')';
	% put solution in inner points; outer points obtained from boundary image
	img_direct(2:end-1,2:end-1,c) = img_tt;
end