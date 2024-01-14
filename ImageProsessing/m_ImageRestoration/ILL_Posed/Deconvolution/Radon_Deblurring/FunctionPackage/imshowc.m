% An image viewer.
% input : im - input iamge
%         optIn - if 1, we show the color bar, if 0, we don't show the
%         color bar
%         clims - defines the range of intensities to view
%         imRef - the color range is defined by the range that color cover
%         the gamut of both im and imRef
% Taeg Sang Cho, Aug 20 2009
function imshowc(im, optIn, clims, imRef)

if ~exist( 'optIn', 'var' ),
    optIn = 0;
end

if ~exist( 'clims', 'var' ),
    clims = [min(im(:)), max(im(:))];
end

if(exist('imRef', 'var' ))
    clims = [min(min(im(:)), min(imRef(:))), max(max(im(:)), max(imRef(:)))];
end



imshow(im,'DisplayRange',clims)
colormap jet
if(optIn)
    colorbar
end