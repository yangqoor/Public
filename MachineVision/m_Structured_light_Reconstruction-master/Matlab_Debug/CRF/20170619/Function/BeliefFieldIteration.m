function beliefField = BeliefFieldIteration(beliefFieldLast, ...
    pattern, ...
    last_depth_mat, ...
    now_depth_mat, ...
    lineA, ...
    lineB, ...
    lineC, ...
    norm_sigma_u, ...
    norm_sigma_p, ...
    viewportMatrix, ...
    voxelSize, ...
    halfVoxelRange, ...
    halfNeighborRange)
% TODO: Need to be upgrade to deltaDepth

    beliefField = cell(size(beliefFieldLast));

    % Iteration: for every voxel in the beliefField
    Mu_mat = Mu_mat_generation(voxelSize, halfVoxelRange);
    ij_mat = ij_alpha(halfNeighborRange, norm_sigma_p);

    for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
        for w = viewportMatrix(1, 1):viewportMatrix(1, 2)

            beliefField{h, w} = zeros(halfVoxelRange * 2 + 1, 1);
            
            x_p = depth2xpro(w, h, now_depth_mat(h, w));
            y_p = xpro2ypro(w, h, x_p, lineA, lineB, lineC);
            c_xy = GetColorByXYpro(x_p, y_p, pattern);

            for d_idx = 1:halfVoxelRange * 2 + 1

                % Calculate depth value
                delta_depth = (d_idx - halfVoxelRange + 1) * voxelSize;
                depth = last_depth_mat(h, w) + delta_depth;
                % Get xpro, ypro from depth
                xpro = depth2xpro(w, h, depth);
                ypro = xpro2ypro(w, h, xpro, lineA, lineB, lineC);
                p_xy = GetColorByXYpro(xpro, ypro, pattern);
                % Set initial value
                tmp_exp = Phi_u(delta_depth, norm_sigma_u);
                % calculate sum
                sum_exp = 0;
                for h_s = 1:halfNeighborRange*2 + 1
                    for w_s = 1:halfNeighborRange*2 + 1
                        h_neighbor = h + h_s - halfNeighborRange - 1;
                        w_neighbor = w + w_s - halfNeighborRange - 1;
                        if (h_neighbor > viewportMatrix(2, 1)) ...
                            && (h_neighbor < viewportMatrix(2, 2)) ...
                            && (w_neighbor > viewportMatrix(1, 1)) ...
                            && (w_neighbor < viewportMatrix(1, 2))
                            sum_exp = ij_mat(h_s, w_s) ...
                                * Mu_mat(d_idx,:) * beliefFieldLast{h_neighbor, w_neighbor};
                        end
                    end
                end
                alpha = color_alpha(c_xy, p_xy);
                beliefField{h, w}(d_idx) = alpha * exp(- tmp_exp - sum_exp);
            end
            sum_value = sum(beliefField{h, w});
            if sum_value == 0
                disp([h, w])
            end
            beliefField{h, w} = beliefField{h, w} / sum_value;
        end
        if mod(h, 10) == 0
            fprintf('.')
        end
    end

end
