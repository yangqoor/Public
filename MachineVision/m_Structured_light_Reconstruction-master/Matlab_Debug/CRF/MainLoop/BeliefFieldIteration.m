function beliefField = BeliefFieldIteration(beliefFieldLast, ...
    cameraImageNorm, ...
    pattern, ...
    last_depth_mat, ...
    viewportMatrix, ...
    voxelSize, ...
    halfVoxelRange)

    beliefField = zeros(size(beliefFieldLast));
    halfNeighborRange = 7;

    % Iteration: for every voxel in the beliefField
    for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
        for w = viewportMatrix(1, 1):viewportMatrix(1, 2)
            c_xy = cameraImageNorm(h, w);
            for d_idx = 1:2*halfVoxelRange+1
                % Calculate depth and color value
                delta_depth = (d_idx - halfVoxelRange + 1) * voxelSize;
                depth = last_depth_mat(h, w) + delta_depth;
                p_xy = GetColorByDepth(w, h, depth, pattern);
                % Set initial value
                tmp_exp = Phi_p(delta_depth, c_xy, p_xy);
                % calculate sum
                sum_exp = 0;
                for hd = -halfNeighborRange:halfNeighborRange
                    for wd = -halfNeighborRange:halfNeighborRange
                        h_neighbor = h + hd;
                        w_neighbor = w + wd;
                        if (h_neighbor > viewportMatrix(2, 1)) ...
                            && (h_neighbor < viewportMatrix(2, 2)) ...
                            && (w_neighbor > viewportMatrix(1, 1)) ...
                            && (w_neighbor < viewportMatrix(1, 2))
                            distance_value = K_distance(w, h, ...
                                w_neighbor, h_neighbor);
                            for d_idx_n = 1:2*halfVoxelRange+1
                                delta_depth_n = (d_idx_n - halfVoxelRange + 1) * voxelSize;
                                depth_n = last_depth_mat(h_neighbor, w_neighbor) + delta_depth_n;
                                mu_value = Mu_depth(depth, depth_n);
                                sum_exp = sum_exp + distance_value ...
                                    * mu_value ...
                                    * beliefFieldLast(h_neighbor, w_neighbor, d_idx_n);
                            end
                        end
                    end
                end
                alpha = 1 - abs(p_xy - c_xy);
                beliefField(h, w, d_idx) = alpha * exp(-tmp_exp-sum_exp);
            end
            sum_value = sum(beliefField(h, w, :));
            beliefField(h, w, :) = beliefField(h, w, :) / sum_value;
        end
        if mod(h, 10) == 0
            fprintf('.')
        end
    end

end
