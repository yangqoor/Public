function value = Mu_depth( depth1, depth2 )
    alpha_mu = 1.0;
    value = alpha_mu * (depth1 - depth2)^2;
end

