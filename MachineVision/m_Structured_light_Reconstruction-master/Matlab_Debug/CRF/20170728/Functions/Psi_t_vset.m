function v_i_set_mat = Psi_t_vset(belief_field, ...
    mask_mats, ...
    cal_para, ...
    viewportMatrix)

    [LAYER_NUM, ~] = size(belief_field);
    [CAMERA_HEIGHT, CAMERA_WIDTH] = size(belief_field{1, 1});

    % delta_depth_set generation
    delta_depth_set = cell(LAYER_NUM, 1);
    for l = 1:LAYER_NUM
        delta_depth_set{l, 1} = GetDeltaDepthFromBeliefField(belief_field{l, 1}, ...
            viewportMatrix, ...
            cal_para.voxelSize, ...
            cal_para.hVoxelRange);
    end

    % set total_mask_mat
    total_mask_mat = zeros(CAMERA_HEIGHT, CAMERA_WIDTH);
    for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
        for w = viewportMatrix(1, 1):viewportMatrix(1, 2)
            for l = 1:LAYER_NUM
                if mask_mats{l, 1}(h, w) == 1
                    total_mask_mat(h, w) = 1;
                    break;
                end
            end
        end
    end

    % Calculate v_i_set_mat
    v_i_set_mat = cell(CAMERA_HEIGHT, CAMERA_WIDTH);
    ij_mat_t = ij_alpha(cal_para.hMaskSRange, cal_para.norm_sigma_t);
    for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
        for w = viewportMatrix(1, 1):viewportMatrix(1, 2)
            v_i_set_mat{h, w} = zeros(LAYER_NUM, 1);
            if total_mask_mat(h, w) == 1
                for l = 1:LAYER_NUM
                    v_i_tmp = 0;
                    total_weight = 0;
                    for h_s = 1:cal_para.hMaskSRange*2 + 1
                        for w_s = 1:cal_para.hMaskSRange*2 + 1
                            h_nbor = h + h_s - cal_para.hMaskSRange - 1;
                            w_nbor = w + w_s - cal_para.hMaskSRange - 1;
                            if (h_nbor > viewportMatrix(2, 1)) ...
                                && (h_nbor < viewportMatrix(2, 2)) ...
                                && (w_nbor > viewportMatrix(1, 1)) ...
                                && (w_nbor < viewportMatrix(1, 2))
                                if mask_mats{l, 1}(h_nbor, w_nbor) == 1
                                    v_i_tmp = v_i_tmp ...
                                        + ij_mat_t(h_s, w_s) * delta_depth_set{l, 1}(h_nbor, w_nbor);
                                    total_weight = total_weight + ij_mat_t(h_s, w_s);
                                end
                            end
                        end
                    end
                    if total_weight == 0
                        v_i_set_mat{h, w}(l, 1) = 0;
                    end
%                     v_i_set_mat{h, w}(l, 1) = v_i_tmp / total_weight;
                end
            end
        end
    end

end
