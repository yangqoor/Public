function depthMatrix = debugGetDepthFromBeliefField(beliefField, ...
    last_depth_mat, ...
    viewportMatrix, ...
    voxelSize, ...
    halfVoxelRange)

    [CAMERA_HEIGHT, CAMERA_WIDTH] = size(beliefField);

    depthMatrix = zeros(size(last_depth_mat));
    for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
        for w = viewportMatrix(1, 1):viewportMatrix(1, 2)
            
            if h == 700 && w == 400
                fprintf('');
            end
            
            [~, max_idx] = max(beliefField{h, w});
            delta_depth = (max_idx - halfVoxelRange - 1) * voxelSize;
            depthMatrix(h, w) = last_depth_mat(h, w) + delta_depth;
        end
    end

end
