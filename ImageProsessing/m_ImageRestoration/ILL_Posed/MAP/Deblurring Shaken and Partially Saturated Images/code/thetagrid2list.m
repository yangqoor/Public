
%	Author:		Oliver Whyte <oliver.whyte@ens.fr>
%	Date:		November 2011
%	Copyright:	2011, Oliver Whyte
%	Reference:  O. Whyte, J. Sivic and A. Zisserman. ``Deblurring Shaken and Partially Saturated Images''. In Proc. CPCV Workshop at ICCV, 2011.
%	URL:		http://www.di.ens.fr/willow/research/saturation/

function theta_list = thetagrid2list(tt,use_rotations)
if nargin < 2 || isempty(use_rotations)
    theta_list = [tt{2}(:),tt{1}(:),tt{3}(:)]';
else
    theta_list = [tt{2}(use_rotations),tt{1}(use_rotations),tt{3}(use_rotations)]';
end