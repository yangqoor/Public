function Mu_mats = Mu_mats_generation( depth_mats, ...
    viewportMatrix, ...
    voxelSize, ...
    halfVoxelRange )
    [layer_num, ~] = size(depth_mats);
    Mu_mats = cell(layer_num, 1);
    Mu_mat = zeros(halfVoxelRange * 2 + 1);
    
    for i = 1:layer_num
        depth_range = depth_mats{i, 1}(viewportMatrix(2,1):viewportMatrix(2,2), ...
            viewportMatrix(1,1):viewportMatrix(1,2));
        max_depth_val = max(max(depth_range));
        min_depth_val = min(min(depth_range));
        
    end
    
    for h = 1:halfVoxelRange * 2 + 1
        for w = 1:h-1
            dVal = (h - w) * voxelSize;
            Mu_mat(h, w) = dVal^2;
            Mu_mat(w, h) = Mu_mat(h, w);
        end
    end
end
