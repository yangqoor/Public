function imshown(I)

I = I-min(I(:));
imshow(I/max(I(:)));