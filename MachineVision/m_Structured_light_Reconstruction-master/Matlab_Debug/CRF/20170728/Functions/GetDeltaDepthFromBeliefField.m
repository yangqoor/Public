function delta_depth_mat = GetDeltaDepthFromBeliefField(beliefField, ...
    viewportMatrix, ...
    voxelSize, ...
    halfVoxelRange)

    delta_depth_mat = zeros(size(beliefField));
    for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
        for w = viewportMatrix(1, 1):viewportMatrix(1, 2)
            [~, max_idx] = max(beliefField{h, w});
            delta_depth = (max_idx - halfVoxelRange - 1) * voxelSize;
            delta_depth_mat(h, w) = delta_depth;
        end
    end

end
