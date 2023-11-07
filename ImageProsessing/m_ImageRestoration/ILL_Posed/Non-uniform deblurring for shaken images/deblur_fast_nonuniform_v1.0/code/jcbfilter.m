% Joint / cross bilateral filter
% Ilow = jcbfilter(Iin,Iguide,sigma_spatial,sigma_range,window_width)

%	Author:		Oliver Whyte <oliver.whyte@ens.fr>
%	Date:		November 2011
%	Copyright:	2011, Oliver Whyte
%	Reference:  O. Whyte, J. Sivic and A. Zisserman. ``Deblurring Shaken and Partially Saturated Images''. In Proc. CPCV Workshop at ICCV, 2011.
%	URL:		http://www.di.ens.fr/willow/research/saturation/

function Ilow = jcbfilter(Iin,Iguide,sigma_spatial,sigma_range,window_width)

[h,w,channels] = size(Iin);

if nargin < 3, sigmad = 1.6;  else sigmad = sigma_spatial; end
if nargin < 4, sigmar = 0.08; else sigmar = sigma_range; end
if nargin < 5, whs = ceil(3*sigmad); else whs = ceil((window_width-1)/2); end

sigmad2 = 2*sigmad^2;
sigmar2 = 2*sigmar^2;


[wx,wy] = meshgrid(-whs:whs,-whs:whs);

Gd = exp(-(wx.^2+wy.^2)/sigmad2);

% Gd(ceil(end/2))=0;

Ilow = zeros(h,w,channels);
if 1
% compute signal weights on full colour image
    for ir=1:h
        rowsj = max(ir-whs,1):min(ir+whs,h);
        rowswin = rowsj - ir + 1 + whs;
        for ic=1:w
            colsj = max(ic-whs,1):min(ic+whs,w);
            colswin = colsj - ic + 1 + whs;
            sigdiff2 = zeros(length(rowsj),length(colsj));
            for c=1:channels
                sigdiff2 = sigdiff2 + (Iguide(ir,ic,c)-Iguide(rowsj,colsj,c)).^2;
            end
            weights = Gd(rowswin,colswin) .* exp(-sigdiff2/sigmar2/channels);
            weights = weights / sum(weights(:));
            for c=1:channels
                Ilow(ir,ic,c) = sum(sum(weights.*Iin(rowsj,colsj,c)));
            end
        end
    end
else
% filter each channel separately
    for c=1:channels
        for ir=1:h
            rowsj = max(ir-whs,1):min(ir+whs,h);
            rowswin = rowsj - ir + 1 + whs;
            for ic=1:w
                colsj = max(ic-whs,1):min(ic+whs,w);
                colswin = colsj - ic + 1 + whs;
                weights = Gd(rowswin,colswin) .* exp(-((Iguide(ir,ic,c)-Iguide(rowsj,colsj,c)).^2)/sigmar2);
                weights = weights / sum(weights(:));
                Ilow(ir,ic,c) = sum(sum(weights.*Iin(rowsj,colsj,c)));
            end
        end
    end
end
