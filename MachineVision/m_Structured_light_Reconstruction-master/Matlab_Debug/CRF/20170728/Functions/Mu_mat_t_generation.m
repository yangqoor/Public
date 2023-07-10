function Mu_mat_t = Mu_mat_t_generation( norm, halfVoxelRange )
    Mu_mat_t = zeros(halfVoxelRange * 2 + 1);
    for h = 1:halfVoxelRange * 2 + 1
        for w = 1:h
            dVal = abs(h - w);
            Mu_mat_t(h, w) = exp( - dVal^2 / (2 * norm));
            Mu_mat_t(w, h) = Mu_mat_t(h, w);
        end
    end
end
