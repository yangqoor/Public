function imDst = rowboxfilter(imSrc, w)
%   BOXFILTER   O(1) time box filtering using cumulative sum
%
%   - Definition imDst(x, y)=sum(sum(imSrc(x-r:x+r,y-r:y+r)));
%   - Running time independent of r; 
%   - Equivalent to the function: colfilt(imSrc, [2*r+1, 2*r+1], 'sliding', @sum);
%   - But much faster.
[hei, wid] = size(imSrc);
imDst = zeros(hei,wid);
%cumulative sum over X axis
imCum = cumsum(imSrc, 2);
%difference over Y axis
imDst(:, 1:w+1) = imCum(:, 1+w:2*w+1);
imDst(:, w+2:wid-w) = imCum(:, 2*w+2:wid) - imCum(:, 1:wid-2*w-1);
imDst(:, wid-w+1:wid) = repmat(imCum(:, wid), [1, w]) - imCum(:, wid-2*w:wid-w-1);
end