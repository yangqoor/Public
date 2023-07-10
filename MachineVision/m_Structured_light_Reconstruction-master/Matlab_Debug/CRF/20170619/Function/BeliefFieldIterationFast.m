function beliefField = BeliefFieldIterationFast(beliefFieldLast, ...
    camera_image, ...
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

    % Calculate Message_send matrix
    Message_send = cell(size(beliefFieldLast));
    for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
        for w = viewportMatrix(1, 1):viewportMatrix(1, 2)
            Message_send{h, w} = Mu_mat * beliefFieldLast{h, w};
            if h == 700 && w == 400
                tmp_ms = Message_send{h, w};
                save message_send.mat tmp_ms
            end
        end
    end

    sum_exp = cell(size(beliefFieldLast));
    for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
        for w = viewportMatrix(1, 1):viewportMatrix(1, 2)
            sum_exp{h, w} = zeros(halfVoxelRange * 2 + 1, 1);
            for h_s = 1:halfNeighborRange*2 + 1
                for w_s = 1:halfNeighborRange*2 + 1
                    h_neighbor = h + h_s - halfNeighborRange - 1;
                    w_neighbor = w + w_s - halfNeighborRange - 1;
                    if (h_neighbor > viewportMatrix(2, 1)) ...
                        && (h_neighbor < viewportMatrix(2, 2)) ...
                        && (w_neighbor > viewportMatrix(1, 1)) ...
                        && (w_neighbor < viewportMatrix(1, 2))
                        sum_exp{h, w} = sum_exp{h, w} ...
                            + ij_mat(h_s, w_s) * Message_send{h_neighbor, w_neighbor};
                    end
                end
            end
            if h == 700 && w == 400
                tmp_se = sum_exp{h, w};
                save sum_exp.mat tmp_se
            end
        end
        if mod(h, 10) == 0
            fprintf('.');
        end
    end

    beliefField = cell(size(beliefFieldLast));
    for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
        for w = viewportMatrix(1, 1):viewportMatrix(1, 2)
            beliefField{h, w} = zeros(halfVoxelRange * 2 + 1, 1);

%             x_p = depth2xpro(w, h, now_depth_mat(h, w));
%             y_p = xpro2ypro(w, h, x_p, lineA, lineB, lineC);
%             c_xy = GetColorByXYpro(x_p, y_p, pattern);
            c_xy = camera_image(h, w);

            for d_idx = 1:halfVoxelRange * 2 + 1
                % Calculate depth value
                delta_depth = (d_idx - halfVoxelRange + 1) * voxelSize;
                depth = last_depth_mat(h, w) + delta_depth;
                % Get xpro, ypro from depth
                xpro = depth2xpro(w, h, depth);
                ypro = xpro2ypro(w, h, xpro, lineA, lineB, lineC);
                p_xy = GetColorByXYpro(xpro, ypro, pattern);
                alpha = color_alpha(c_xy, p_xy);
                % Set initial value
                tmp_exp = Phi_u(delta_depth, norm_sigma_u);
                beliefField{h, w}(d_idx) = exp(-alpha*tmp_exp-sum_exp{h, w}(d_idx));
            end
            if h == 700 && w == 400
                tmp_bf = beliefField{h, w};
                save belief_field.mat tmp_bf
            end

            sum_value = sum(beliefField{h, w});
            if sum_value == 0
                disp([h, w])
            end
            beliefField{h, w} = beliefField{h, w} / sum_value;
        end
        if mod(h, 10) == 0
            fprintf('x')
        end
    end

end
