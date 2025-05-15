function [m, o]= motion2magori(u, v)
m = sqrt(u.^2 + v.^2);
u(find(u == 0)) = 1e-16;
o = atan(v ./ u) * 180 / pi;
ind = find(o < 0);
o(ind) = o(ind) + 180;

function x = mysign(u)
x = -ones(size(u));
x(find(u >= 0)) = 1;
