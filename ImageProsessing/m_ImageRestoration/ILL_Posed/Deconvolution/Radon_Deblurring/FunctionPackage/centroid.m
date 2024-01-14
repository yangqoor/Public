% Computes the centroid of a two-dimensional vector im
% im = input image
% k = x,y coordinates of the centroid
function k = centroid(im)

[y,x] = meshgrid(1:size(im, 2), 1:size(im, 1));
k = sum(im(:).*x(:))/sum(im(:)); % x-dimension centroid
k(2) = sum(im(:).*y(:))/sum(im(:)); % y-dimension centroid
 