function ij_mat = ij_alpha(halfNeighborRange, norm_sigma_p)

    ij_mat = zeros(halfNeighborRange*2 + 1);
    for h = 1:halfNeighborRange * 2 + 1
        for w = 1:halfNeighborRange * 2 + 1
            center_h = h - halfNeighborRange - 1;
            center_w = w - halfNeighborRange - 1;
            distance_val = norm([center_h, center_w]);
            ij_mat(h, w) = exp( - distance_val^2 / (2 * norm_sigma_p^2));
        end
    end
end
