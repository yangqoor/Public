function value = Phi_u(delta_depth, norm_sigma_u)

%     alpha = 1 - abs(p_xy - c_xy);
%     norm_value = normpdf(delta_depth, 0, norm_sigma);
    % alpha = (1 + abs(p_xy - c_xy));
    norm_value = (delta_depth^2) / (2*norm_sigma_u^2);

    value = norm_value;
end
