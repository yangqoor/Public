function depth_mats = FillOriDepthMap(belief_field, ...
    mask_mats, ...
    depth_mats_0, ...
    cal_para, ...
    viewportMatrix)

    % Set total_mask_mat
    total_mask_mat = zeros(size(depth_mats_0));
    for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
        for w = viewportMatrix(1, 1):viewportMatrix(1, 2)
            for l = 1:5
                if mask_mats{l, 1}(h, w) == 1
                    total_mask_mat(h, w) = 1;
                    break;
                end
            end
        end
    end

    depth_mats = cell(5, 1);
    depth_mats{1, 1} = depth_mats_0;
    for i = 2:5
        % Get delta_depth_mat from belief field
        delta_depth_mat = zeros(size(depth_mats_0));
        for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
            for w = viewportMatrix(1, 1):viewportMatrix(1, 2)
                if mask_mats{i-1, 1}(h, w) == 1
                    [~, max_idx] = max(belief_field{i-1, 1}{h, w});
                    delta_depth = (max_idx - cal_para.hVoxelRange - 1) * cal_para.voxelSize;
                    delta_depth_mat(h, w) = delta_depth;
                end
            end
        end
        % Fill depth_mats with intersection
        depth_mats{i, 1} = zeros(size(depth_mats_0));
        for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
            for w = viewportMatrix(1, 1):viewportMatrix(1, 2)
                if total_mask_mat(h, w) == 1 && mask_mats{i-1, 1}(h, w) == 0
                    point_set = FindNearestPoint(cal_para.k_nearest, ...
                        h, ...
                        w, ...
                        mask_mats{i - 1, 1}, ...
                        viewportMatrix);
                    point_set_dis = sqrt(point_set(:, 1).^2 + point_set(:, 2).^2);
                    d_max = sum(point_set_dis);
                    weighted = (ones(cal_para.k_nearest, 1) - point_set_dis/d_max).^2;
                    weighted = weighted / sum(weighted);
                    delta_depth_mat(h, w) = 0;
                    for p = 1:cal_para.k_nearest
                        h_idx = point_set(p, 1) + h;
                        w_idx = point_set(p, 2) + w;
                        delta_depth_mat(h, w) = delta_depth_mat(h, w) + weighted(p, 1) * delta_depth_mat(h_idx, w_idx);
                    end
                    depth_mats{i, 1}(h, w) = depth_mats{i-1, 1}(h, w) + delta_depth_mat(h, w);
                end
            end
        end
    end

end
