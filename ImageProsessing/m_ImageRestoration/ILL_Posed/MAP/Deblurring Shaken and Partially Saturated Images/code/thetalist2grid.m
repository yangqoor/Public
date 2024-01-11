
%	Author:		Oliver Whyte <oliver.whyte@ens.fr>
%	Date:		November 2011
%	Copyright:	2011, Oliver Whyte
%	Reference:  O. Whyte, J. Sivic and A. Zisserman. ``Deblurring Shaken and Partially Saturated Images''. In Proc. CPCV Workshop at ICCV, 2011.
%	URL:		http://www.di.ens.fr/willow/research/saturation/

function tt = thetalist2grid(theta_list)

error('haven''t checked this function carefully')

tgsx = median(diff(sort(unique(theta_list(1,:)))));
tgsy = median(diff(sort(unique(theta_list(2,:)))));
tgsz = median(diff(sort(unique(theta_list(3,:)))));

minx = min(theta_list(1,:));    maxx = max(theta_list(1,:));
miny = min(theta_list(2,:));    maxy = max(theta_list(2,:));
minz = min(theta_list(3,:));    maxz = max(theta_list(3,:));

nx = round((maxx-minx) / tgsx) + 1;
ny = round((maxy-miny) / tgsy) + 1;
nz = round((maxz-minz) / tgsz) + 1;

[ttx,tty,ttz] = meshgrid(linspace(minx,maxx,nx),linspace(miny,maxy,ny),linspace(minz,maxz,nz));

tt = {tty,ttx,ttz};
