function beliefField = FillInitialBeliefField(cameraImageNorm, ...
    pattern, ...
    last_x_gt, last_y_gt, ...
    viewportMatrix, ...
    voxelSize, ...
    halfVoxelRange)

    [CAMERA_HEIGHT, CAMERA_WIDTH] = size(cameraImageNorm);
    beliefField = zeros(CAMERA_HEIGHT, CAMERA_WIDTH, halfVoxelRange * 2 + 1);

    % For every point in the QField
    for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
        for w = viewportMatrix(1, 1):viewportMatrix(1, 2)
            for d_idx = 1:halfVoxelRange * 2 + 1
                % Calculate depth value
                delta_depth = (d_idx - halfVoxelRange + 1) * voxelSize;
                depth = last_depth_mat(h, w) + delta_depth;
                % Get color information
                p_xy = GetColorByDepth(w, h, depth, pattern);
                c_xy = cameraImageNorm(h, w);
                alpha = 1 - abs(p_xy - c_xy);
                beliefField(h, w, d_idx) = alpha * exp(-Phi_p(delta_depth, c_xy, p_xy));
            end
            % Normalize
            sum_value = sum(beliefField(h, w, :));
            beliefField(h, w, :) = beliefField(h, w, :) / sum_value;
        end
    end

end
