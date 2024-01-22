% function imlinear = srgb2linear(imsrgb)
% convert sRGB non-linear values to linear tristimulus values

%	Author:		Oliver Whyte <oliver.whyte@ens.fr>
%	Date:		November 2011
%	Copyright:	2011, Oliver Whyte
%	Reference:  O. Whyte, J. Sivic and A. Zisserman. ``Deblurring Shaken and Partially Saturated Images''. In Proc. CPCV Workshop at ICCV, 2011.
%	URL:		http://www.di.ens.fr/willow/research/saturation/

function imlinear = srgb2linear(imsrgb)
thresh = 0.0031308; % linear domain threshold value between linear/power sections
slope  = 12.92;     % slope of linear section in linear2srgb
a      = 0.055;     % offset
gamma  = 2.4;       % power of power section
srgbthresh = slope*thresh; % threshold converted to sRGB domain
imlinear = (imsrgb<=srgbthresh).*imsrgb/slope + (imsrgb>srgbthresh).*((imsrgb+a)/(1+a)).^gamma;