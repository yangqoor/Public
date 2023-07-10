function [top_left, top_right, bottom_right, bottom_left] = QuadrantEnergy(G)
%QUADRANTENERGY Returns the energy percentage of each quadrant
%   Takes a matrix and divides it into 4 submatrices numbered q1-q4. It 
%   calculates the energy percentage for each quadrant. The
%   values are arranged clockwise staring from top-left, q1.

sum_G = sum(G(:));

[tl, tr, br, bl] = Quadrants(G);
top_left = sum(tl(:)) / sum_G;
top_right = sum(tr(:)) / sum_G;
bottom_right = sum(br(:)) / sum_G;
bottom_left = sum(bl(:)) / sum_G;

end