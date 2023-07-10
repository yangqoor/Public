function value = Phi_u(alpha, delta_depth, norm_sigma_u)

    epsilon = 0.001;
%     alpha = 1 - abs(p_xy - c_xy);
%     norm_value = normpdf(delta_depth, 0, norm_sigma);
    % alpha = (1 + abs(p_xy - c_xy));
    norm_value = (delta_depth^2) / (2*norm_sigma_u^2) + epsilon;
    % norm_value = epsilon;

    value = max(alpha, norm_value);
end
