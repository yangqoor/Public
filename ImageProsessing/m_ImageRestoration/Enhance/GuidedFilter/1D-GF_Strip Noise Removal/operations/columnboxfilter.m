function imDst = columnboxfilter(imSrc, h)

%   BOXFILTER   O(1) time box filtering using cumulative sum
%
%   - Definition imDst(x, y)=sum(sum(imSrc(x-r:x+r,y-r:y+r)));
%   - Running time independent of r; 
%   - Equivalent to the function: colfilt(imSrc, [2*r+1, 2*r+1], 'sliding', @sum);
%   - But much faster.
[hei, wid] = size(imSrc);
imDst = zeros(hei,wid);
%cumulative sum over Y axis
imCum = cumsum(imSrc, 1);
%difference over Y axis
imDst(1:h+1, :) = imCum(1+h:2*h+1, :);
imDst(h+2:hei-h, :) = imCum(2*h+2:hei, :) - imCum(1:hei-2*h-1, :);
imDst(hei-h+1:hei, :) = repmat(imCum(hei, :), [h, 1]) - imCum(hei-2*h:hei-h-1, :);
end