function beliefField = FillInitialBeliefFieldFromDepth(camera_image, ...
    last_depth_mat, ...
    now_depth_mat, ...
    viewportMatrix, ...
    para)

    [CAMERA_HEIGHT, CAMERA_WIDTH] = size(camera_image);
    beliefField = cell(CAMERA_HEIGHT, CAMERA_WIDTH);
    omega = 1;
    epsilon = 0.01;

    % For every point in the QField
    delta_depth_mat = now_depth_mat - last_depth_mat;
    for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
        for w = viewportMatrix(1, 1):viewportMatrix(1, 2)
            beliefField{h, w} = epsilon * ones(para.halfVoxelRange * 2 + 1, 1);
            delta_depth_voxel = round(delta_depth_mat(h, w) / para.voxelSize);
            delta_depth_idx = para.halfVoxelRange + 1 + delta_depth_voxel;
            if delta_depth_idx <= 0 || delta_depth_idx > 2 * para.halfVoxelRange + 1
                delta_depth_idx = para.halfVoxelRange + 1;
            end
            for d = 1:para.halfVoxelRange*2+1
                beliefField{h, w}(d, 1) = exp(-(delta_depth_idx - d)^2 / 2 * omega^2);
            end
            % beliefField{h, w}(delta_depth_idx, 1) = 1;

            sum_value = sum(beliefField{h, w});
            if sum_value == 0
                disp(h, w)
            end
            beliefField{h, w} = beliefField{h, w} / sum_value;
        end
    end

end
