function belief_field = BeliefFieldIterationT(belief_field_last, ...
    camera_image, ...
    mask_mats, ...
    depth_mat_ori, ...
    pattern, ...
    epi_para, ...
    cal_para, ...
    viewportMatrix)

    [LAYER_NUM, ~] = size(belief_field_last);
    [CAMERA_HEIGHT, CAMERA_WIDTH] = size(belief_field_last{1, 1});
    belief_field = cell(LAYER_NUM, 1);

    % Iteration: for every voxel in the beliefField
    Mu_mat = Mu_mat_generation(cal_para.voxelSize, cal_para.hVoxelRange);
    ij_mat_p = ij_alpha(cal_para.hNborRange, cal_para.norm_sigma_p);

    % Calculate Message_send matrix for psi_p
    Message_sends = cell(LAYER_NUM, 1);
    for l = 1:LAYER_NUM
        Message_sends{l, 1} = cell(CAMERA_HEIGHT, CAMERA_WIDTH);
        for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
            for w = viewportMatrix(1, 1):viewportMatrix(1, 2)
                Message_sends{l, 1}{h, w} = Mu_mat * belief_field_last{l, 1}{h, w};
            end
        end
    end

    % psi_p calculation
    psi_p_exp = cell(LAYER_NUM, 1);
    for l = LAYER_NUM:-1:1
        psi_p_exp{l, 1} = cell(CAMERA_HEIGHT, CAMERA_WIDTH);
        for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
            for w = viewportMatrix(1, 1):viewportMatrix(1, 2)
                psi_p_exp{l, 1}{h, w} = zeros(cal_para.hVoxelRange * 2 + 1, 1);
                if mask_mats{l, 1}(h, w) == 0
                    continue
                end
                
                if h == 285 && w == 720 && l == 5
                    fprintf('');
                end
                
                for h_s = 1:cal_para.hNborRange*2 + 1
                    for w_s = 1:cal_para.hNborRange*2 + 1
                        h_nbor = h + h_s - cal_para.hNborRange - 1;
                        w_nbor = w + w_s - cal_para.hNborRange - 1;
                        if (h_nbor > viewportMatrix(2, 1)) ...
                            && (h_nbor < viewportMatrix(2, 2)) ...
                            && (w_nbor > viewportMatrix(1, 1)) ...
                            && (w_nbor < viewportMatrix(1, 2))
                            if mask_mats{l, 1}(h_nbor, w_nbor) == 1
                                psi_p_exp{l, 1}{h, w} = psi_p_exp{l, 1}{h, w} ...
                                    + ij_mat_p(h_s, w_s) * Message_sends{l, 1}{h_nbor, w_nbor};
                            end
                        end
                    end
                end
            end
            if mod(h, 40) == 0
                fprintf('s');
            end
        end
        fprintf(',');
    end
    fprintf('\n');

    % psi_t calculation: v_i_set_mat
    v_i_set_mat = Psi_t_vset(belief_field_last, ...
        mask_mats, ...
        cal_para, ...
        viewportMatrix);

    % psi_t calculation: XWX for regression
%     Mu_mat_t = Mu_mat_t_generation(0.5, 2);
    Mu_mat_t = ones(5, 5);
    XWX_1_set = cell(LAYER_NUM, 1);
    XW_set = cell(LAYER_NUM, 1);
    X_mat = [1,2,3,4,5; 1,1,1,1,1]';
    for l = 1:LAYER_NUM
        Weight_mat = diag(Mu_mat_t(l, :));
        XWX_1_set{l, 1} = inv(X_mat'*Weight_mat*X_mat);
        XW_set{l, 1} = X_mat'*Weight_mat;
    end

    % psi_t calculation
    psi_t_exp = cell(LAYER_NUM, 1);
    for l = 1:LAYER_NUM
        psi_t_exp{l, 1} = cell(CAMERA_HEIGHT, CAMERA_WIDTH);
        for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
            for w = viewportMatrix(1, 1):viewportMatrix(1, 2)
                if mask_mats{l, 1}(h, w) == 0
                    continue;
                end
                tmp_beta = XWX_1_set{l, 1}*XW_set{l, 1}*v_i_set_mat{h, w};
                v_reg = X_mat * tmp_beta;
                psi_t_exp{l, 1}{h, w} = Psi_t_cal(v_reg(l, 1), cal_para);
            end
        end
    end

    % belief_field iteration
    for l = 1:LAYER_NUM
        belief_field{l, 1} = cell(CAMERA_HEIGHT, CAMERA_WIDTH);
        for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
            for w = viewportMatrix(1, 1):viewportMatrix(1, 2)
                belief_field{l, 1}{h, w} = zeros(2*cal_para.hVoxelRange + 1, 1);
                c_xy = camera_image{l + 1, 1}(h, w);

                if mask_mats{l, 1}(h, w) == 0
                    continue
                end

                if h == 285 && w == 720 && l == 5
                    fprintf('');
                end
                
                for d_idx = 1:cal_para.hVoxelRange * 2 + 1
                    % Psi_u: Calculate depth value
                    delta_depth = (d_idx - cal_para.hVoxelRange - 1) * cal_para.voxelSize;
                    depth = depth_mat_ori{l, 1}(h, w) + delta_depth;
                    % Psi_u: Get xpro, ypro from depth
                    xpro = depth2xpro(w, h, depth);
                    ypro = xpro2ypro(w, h, xpro, epi_para);
                    p_xy = GetColorByXYpro(xpro, ypro, pattern);
                    % Psi_u calculation
                    alpha = color_alpha(c_xy, p_xy);
                    tmp_exp_u = Phi_u(alpha, delta_depth, cal_para.norm_sigma_u);
                    % Psi_p, Psi_t calculation
                    tmp_exp_p = psi_p_exp{l, 1}{h, w}(d_idx);
                    tmp_exp_t = psi_t_exp{l, 1}{h, w}(d_idx);

                    belief_field{l, 1}{h, w}(d_idx) = exp( ...
                        -cal_para.omega_u * tmp_exp_u ...
                        -cal_para.omega_p * tmp_exp_p ...
                        -cal_para.omega_t * tmp_exp_t);
                end

                sum_value = sum(belief_field{l, 1}{h, w});
                if sum_value == 0
                    disp([h, w])
                end
                belief_field{l, 1}{h, w} = belief_field{l, 1}{h, w} / sum_value;
            end
            if mod(h, 40) == 0
                fprintf('u');
            end
        end
        fprintf(',');
    end
    fprintf('\n');

end
