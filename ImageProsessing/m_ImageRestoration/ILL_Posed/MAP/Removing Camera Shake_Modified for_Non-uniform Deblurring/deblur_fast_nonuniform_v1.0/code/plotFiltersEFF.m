% B=plotFiltersEFF(eff,kernel,scale)

%	Author:		Oliver Whyte <oliver.whyte@ens.fr>
%	Date:		November 2011
%	Copyright:	2011, Oliver Whyte
%	Reference:  O. Whyte, J. Sivic and A. Zisserman. ``Deblurring Shaken and Partially Saturated Images''. In Proc. CPCV Workshop at ICCV, 2011.
%	URL:		http://www.di.ens.fr/willow/research/saturation/

function B=plotFiltersEFF(eff,kernel,scale)
if nargin < 3, scale = 1; end
filt_stack = computeFilterStackEFF(eff,kernel,0);
for gi=1:size(filt_stack,4),
    filt_stack(:,:,:,gi) = fftshift(filt_stack(:,:,:,gi));
end

% w = ceil(1.5*max(eff.psf_size));
w = round(1/scale*mean((eff.padded_size-[eff.pad(1)+eff.pad(2), eff.pad(3)+eff.pad(4)]) ./ eff.grid_size)/3);
filt_stack = filt_stack(end/2+(-w:w),end/2+(-w:w),:,:);

gi=0;
B = ones(eff.grid_size*(2*w+3));
for gx=1:eff.grid_size(2)
    for gy=1:eff.grid_size(1)
        gi=gi+1;
        B((gy-1)*(2*w+3)+(2:2*w+2),(gx-1)*(2*w+3)+(2:2*w+2)) = filt_stack(:,:,:,gi)/max(max(max(max(filt_stack(:,:,:,gi)))));
    end
end

    