function value = K_distance( x1, y1, x2, y2 )
    alpha_k = 1;
    distance_val = (x1-x2)^2 + (y1-y2)^2;
    value = exp(- distance_val / (2 * alpha_k^2));
end

