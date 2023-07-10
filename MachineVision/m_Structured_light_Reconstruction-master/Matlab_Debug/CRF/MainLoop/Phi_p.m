function value = Phi_p(delta_depth, c_xy, p_xy)
    norm_sigma = 2;

%     alpha = 1 - abs(p_xy - c_xy);
%     norm_value = normpdf(delta_depth, 0, norm_sigma);
    alpha = (1 + abs(p_xy - c_xy));
    norm_value = (delta_depth^2) / (2*norm_sigma^2);
    
    value = norm_value;
end
