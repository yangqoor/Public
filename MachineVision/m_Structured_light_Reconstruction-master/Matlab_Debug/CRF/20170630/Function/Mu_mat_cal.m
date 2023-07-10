function [ mu_mat ] = Mu_mat_cal(depth_left, depth_right, voxelSize, halfVoxelRange)

    mu_mat = zeros(halfVoxelRange*2+1);
    
    for h = 1:halfVoxelRange*2 + 1
        for w = 1:halfVoxelRange*2 + 1
            dVal = (depth_left + h - depth_right - w) * voxelSize;
            mu_mat(h, w) = dVal^2;
        end
    end

end

