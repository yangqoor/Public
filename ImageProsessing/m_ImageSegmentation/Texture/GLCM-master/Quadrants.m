function [top_left, top_right, bottom_right, bottom_left] = Quadrants(G)
%QUADRANTS Takes a matrix and divides it into 4 submatrices
%   Takes a matrix and divides it into 4 submatrices numbered q1-q4. The
%   submatrices are arranged clockwise staring from top-left, q1.

[rows, columns] = size(G);
half_rows = rows / 2;
half_columns = columns / 2;

top_left = G(1:half_rows, 1:half_columns);
top_right = G(1:half_rows, half_columns + 1:columns);
bottom_right = G(half_rows + 1:rows, half_columns + 1:columns);
bottom_left = G(half_rows + 1:rows, 1:half_columns);

end

