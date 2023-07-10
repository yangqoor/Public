function total_field = BeliefFieldIterationFast(total_field_last, ...
    camera_image, ...
    pattern, ...
    depth_mats, ...
    lineA, ...
    lineB, ...
    lineC, ...
    viewportMatrix, ...
    para)
    % norm_sigma_u, ...
    % norm_sigma_t, ...
    % norm_sigma_p, ...
    % viewportMatrix, ...
    % voxelSize, ...
    % halfVoxelRange, ...
    % halfNeighborRange)
% TODO: Need to be upgrade to deltaDepth

    total_field = cell(size(total_field_last));
    [CAMERA_HEIGHT, CAMERA_WIDTH] = size(total_field_last{1});

    % Iteration: for every voxel in the beliefField
    Mu_mat = Mu_mat_generation(para.voxelSize, para.halfVoxelRange);
    ij_mat = ij_alpha(para.halfNeighborRange, para.norm_sigma_p);
    t_mat = t_alpha(4, para.norm_sigma_t);

    % Calculate Message_send matrix
    Message_sendS = cell(size(total_field_last));
    for i = 1:4
        Message_sendS{i, 1} = cell(CAMERA_HEIGHT, CAMERA_WIDTH);
        for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
            for w = viewportMatrix(1, 1):viewportMatrix(1, 2)
                Message_sendS{i, 1}{h, w} = Mu_mat * total_field_last{i, 1}{h, w};
%                 if h == 700 && w == 400
%                     tmp_ms = Message_sendS{i, 1}{h, w};
%                     save message_send.mat tmp_ms
%                 end
            end
        end
    end

    % Calculate Sum of \psi_S for every pixel
    psi_S_sum = cell(size(total_field_last));
    for i = 1:4
        psi_S_sum{i, 1} = cell(size(CAMERA_HEIGHT, CAMERA_WIDTH));
        for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
            for w = viewportMatrix(1, 1):viewportMatrix(1, 2)
                psi_S_sum{i, 1}{h, w} = zeros(para.halfVoxelRange * 2 + 1, 1);
                % depth_origin = depth_mats{i, 1}(h, w);
                for h_s = 1:para.halfNeighborRange*2 + 1
                    for w_s = 1:para.halfNeighborRange*2 + 1
                        h_neighbor = h + h_s - para.halfNeighborRange - 1;
                        w_neighbor = w + w_s - para.halfNeighborRange - 1;
                        if (h_neighbor > viewportMatrix(2, 1)) ...
                                && (h_neighbor < viewportMatrix(2, 2)) ...
                                && (w_neighbor > viewportMatrix(1, 1)) ...
                                && (w_neighbor < viewportMatrix(1, 2))
                            % depth_neighbor = depth_mats{i, 1}(h_neighbor, w_neighbor);
                            % mu_mat = Mu_mat_cal(depth_origin, depth_neighbor, ...
                            %     voxelSize, halfVoxelRange);
                            psi_S_sum{i, 1}{h, w} = psi_S_sum{i, 1}{h, w} ...
                                + ij_mat(h_s, w_s) ...
                                * Message_sendS{i, 1}{h_neighbor, w_neighbor};
                        end
                    end
                end
%                 if h == 700 && w == 400
%                     psi_s_sum = psi_S_sum{i, 1}{h, w};
%                     save psi_s_sum.mat psi_s_sum;
%                 end
            end
            if mod(h, 40) == 0
                fprintf('s');
            end
        end
        fprintf(',');
    end
    fprintf('\n');

    % Calculate \psi_T for every pixel
    psi_T_sum = cell(size(total_field_last));
    for i = 1:4
        psi_T_sum{i, 1} = cell(CAMERA_HEIGHT, CAMERA_WIDTH);
        for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
            for w = viewportMatrix(1, 1):viewportMatrix(1, 2)
                psi_T_sum{i}{h, w} = zeros(para.halfVoxelRange*2+1, 1);
                for t = 1:4
                    if t == i
                        continue
                    else
                        t_vec = t_mat(i, :);
                        psi_T_sum{i, 1}{h, w} = psi_T_sum{i, 1}{h, w} ...
                            + t_vec(t) * Message_sendS{t}{h, w};
                    end
                end
            end
            if mod(h, 40) == 0
                fprintf('t');
            end
        end
        fprintf(',');
    end
    fprintf('\n');

    % Calculate sum
    for i = 1:4
        total_field{i, 1} = cell(CAMERA_HEIGHT, CAMERA_WIDTH);
        for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
            for w = viewportMatrix(1, 1):viewportMatrix(1, 2)
                total_field{i}{h, w} = zeros(para.halfVoxelRange * 2 + 1, 1);

                x_p = depth2xpro(w, h, depth_mats{i + 1}(h, w));
                y_p = xpro2ypro(w, h, x_p, lineA, lineB, lineC);
                c_xy = GetColorByXYpro(x_p, y_p, pattern);
%                 c_xy = camera_image(h, w);

                for d_idx = 1:para.halfVoxelRange * 2 + 1
                    % Calculate depth value
                    delta_depth = (d_idx - para.halfVoxelRange + 1) * para.voxelSize;
                    depth = depth_mats{i}(h, w) + delta_depth;
                    % Get xpro, ypro from depth
                    xpro = depth2xpro(w, h, depth);
                    ypro = xpro2ypro(w, h, xpro, lineA, lineB, lineC);
                    p_xy = GetColorByXYpro(xpro, ypro, pattern);
                    alpha = color_alpha(c_xy, p_xy);
                    % Set initial value
                    psi_u_exp = max(alpha, Phi_u(delta_depth, para.norm_sigma_u));
                    psi_s_exp = psi_S_sum{i}{h, w}(d_idx);
                    psi_t_exp = psi_T_sum{i}{h, w}(d_idx);
                    total_field{i}{h, w}(d_idx) = exp( ...
                        -para.omega_u * psi_u_exp ...
                        -para.omega_s * psi_s_exp ...
                        -para.omega_t * psi_t_exp);
                end
                sum_value = sum(total_field{i}{h, w});
                % if sum_value == 0
                %     disp([h, w])
                % end
                total_field{i}{h, w} = total_field{i}{h, w} / sum_value;
            end
            if mod(h, 40) == 0
                fprintf('u')
            end
        end
        fprintf(',');
    end
    fprintf('\n');

end
