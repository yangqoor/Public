function [ M] = vecToSymmetric4x4Matrix( v )
M=[v(1:4)'; v(2) v(5:7)'; v(3) v(6) v(8:9)'; v(4) v(7) v(9) v(10)];
end

