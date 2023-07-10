function Mu_mat = Mu_mat_generation( voxelSize, halfVoxelRange )
    Mu_mat = zeros(halfVoxelRange * 2 + 1);
    for h = 1:halfVoxelRange * 2 + 1
        for w = 1:h-1
            dVal = (h - w) * voxelSize;
            Mu_mat(h, w) = dVal^2;
            Mu_mat(w, h) = Mu_mat(h, w);
        end
    end
end
