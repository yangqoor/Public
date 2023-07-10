function [points,labels] = makegaussmixnd (centers, stdevs, ppm, doplot)
% MAKEGAUSSMIXND Produces points randomly sampled from a Gaussian Mixture Model in N-dimensions %
% [points,labels] = makegaussmixNd (centers, stdevs, ppm, [doplot]) %
% centers is a M x N matrix. % stdevs is a M-long vector, or a single value
% numpts per mixture is an integer or an M-long vector
% There are M N-dimensional mixture models.
% The m-th mixture is centered at (centers(m,1),...,centers(m,N))
% and has standard deviation stdevs (if its an integer) or stdevs(m) in each dimension with a diagonal correlation matrix.
% ppm (if ppm is an integer) or ppm (if it's a M-long vector) points are sampled from it.
% if doplot is provided, it should be a M-long character string with valid colors. %
% The number of points generated is P = ppm*M or sum(ppm)
% depending on whether ppm is an integer or an m-long vector respectively. %
% points is a P x N matrix % labels is a P-long vector % points(i,:) = (points(i,1),..,points(i,N)) is the i-th point and comes from the % labels(i)-th mixture model. % % Dinoj Surendran (dinoj@cs.uchicago.edu) % 15 May 2004 %
% Example:[points,labels]=makegaussmixnd(4,[0 0; 0 5; 5 0; 5 5],1,500); % generates 2000 points, % 500 are from a gaussian distribution centered at (0,0) with stdeviation 1 % 500 are from a gaussian distribution centered at (0,5) with stdeviation 1 % 500 are from a gaussian distribution centered at (5,0) with stdeviation 1 % 500 are from a gaussian distribution centered at (5,5) with stdeviation 1 %
% Note: It uses the mvnrnd function that appears in MAtlab 6.5 (but % not 6.0).
if ((nargin < 3) || (nargin > 4))
    error ('This function needs 3 (or 4) arguments! You have sinned. \nType "help makegaussmixnd" and say seventeen Hail Marys.');
end
if (~isnumeric(centers) || (length(size(centers)) ~= 2))
    error (sprintf ('The second argument should be a matrix with %d rows\n',M));
end
M = size(centers,1);
N = size(centers,2);
if (~isnumeric(stdevs) || (length(size(stdevs)) ~= 2) || ((length(stdevs) ~= M) && (length(stdevs)~=1)) | (0 < length(find(stdevs<=0))))
    error (sprintf ('The third argument should be a vector with %d elements, all positive real values\n',M));
end
if (~isnumeric(ppm) || (length(size(ppm)) ~= 2) || ((size(ppm,1)~=1) && (size(ppm,2)~=1)) || ((length(ppm) ~= 1) & (length(ppm) ~= M)))
    error (sprintf('The fourth argument should be a positive integer or a vector with %d positive integers\n',M));
end
if (1==length(ppm))
    ppm = repmat(ppm,1,M);
end
if (1==length(stdevs))
    stdevs = repmat(stdevs,1,M);
end
N = size(centers,2); % dimension of the points
points = []; 
labels = [];
for m=1:M
    labels = [labels repmat(m,1,ppm(m))];
end
P = length(labels);
for pp = 1 : P
    % I hope matlab distinguishes between upper and lower case in windows means
    pp= centers (labels (pp));
end
devs = diag (repmat (stdevs(labels(pp)+1), 1, N));
points = mvnrnd (means,devs);
% assumes Matlab % 6.5 at least
if (nargin == 4) && ischar(doplot) && (M == length(doplot))
    plotcol (points, ppm, doplot);
end
