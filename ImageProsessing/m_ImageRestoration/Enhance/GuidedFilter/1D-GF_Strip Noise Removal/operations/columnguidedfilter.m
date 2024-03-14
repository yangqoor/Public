function q = columnguidedfilter(I, p, r, eps)


[hei, wid] = size(I);
N = columnboxfilter(ones(hei, wid), r); % the size of each local patch; N=(2r+1)^2 except for boundary pixels.

mean_I = columnboxfilter(I, r) ./ N;
mean_p = columnboxfilter(p, r) ./ N;
mean_Ip = columnboxfilter(I.*p, r) ./ N;
cov_Ip = mean_Ip - mean_I .* mean_p; % this is the covariance of (I, p) in each local patch.

mean_II = columnboxfilter(I.*I, r) ./ N;
var_I = mean_II - mean_I .* mean_I;

a = cov_Ip ./ (var_I + eps); % Eqn. (5) in the paper;
b = mean_p - a .* mean_I; % Eqn. (6) in the paper;

mean_a = columnboxfilter(a, r) ./ N;
mean_b = columnboxfilter(b, r) ./ N;

q = mean_a .* I + mean_b; % Eqn. (8) in the paper;
end