function [imLin, imWB,scaleFac] = demosaickDownSample(im, flipOn, scaleFac)%, imWB)

if ~exist('flipOn', 'var')
    flipOn = 0;
end

imOut = zeros(floor(size(im, 1)/2), floor(size(im, 2)/2), 3);

imOut(:, :, 1) = im(1:2:end, 1:2:end);
imOut(:, :, 3) = im(2:2:end, 2:2:end);
imOut(:, :, 2) = (im(1:2:end, 2:2:end) + im(2:2:end, 1:2:end))/2;

if(flipOn == 1)
    imOutT = imOut;
    imOut = zeros(size(imOutT, 2), size(imOutT, 1), size(imOutT, 3));
    for l = 1:size(imOutT, 3)
        imOut(:, :, l) = fliplr(imOutT(:, :, l)');
    end
end

if ~exist('scaleFac', 'var')

    figure, imshow(imOut)
    [y,x] = ginput(1);
    % scaleFac = mean(mean(imWB, 1), 2)./(mean(mean(im, 1), 2));
    scaleFac = imOut(round(x),round(y), :);%[0.0772, 0.2182, 0.2001];
end

scaleFac = reshape(scaleFac, [1, 1, 3]);

imWB = imOut./repmat(scaleFac, [size(imOut, 1), size(imOut, 2)]);
imLin = imOut;
close