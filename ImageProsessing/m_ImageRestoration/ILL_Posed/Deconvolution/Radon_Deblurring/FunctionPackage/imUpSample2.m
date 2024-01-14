function out = imUpSample2(im, scale)
% Upsamples an image by a factor of 2 by "scale" times
% Taeg Sang Cho

if(scale == 0)
    out = im;
    return;
end
scaleLoop = scale;

% Upsampling
out = zeros(2*size(im, 1), 2*size(im, 2), size(im, 3));
out(1:2:end, 1:2:end, :) = im;
out(1:2:end, 2:2:end, :) = im;
out(2:2:end, 1:2:end, :) = im;
out(2:2:end, 2:2:end, :) = im;

% Recursive upsampling
while scaleLoop > 1    
    scaleLoop = scaleLoop - 1;
    out = imUpSample2(out, scaleLoop);
end
% end
