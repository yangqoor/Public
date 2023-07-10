function [projected_vecmat, valid_index, valid_index_size] = fun_ProjectedImage(...
    delta_depth_vec, ...
    color_table, ...
    sigma_table, ...
    CamInfo, ...
    ProInfo, ...
    EpiLine, ...
    C_set, ...
    ParaSet)
% Calculate P

    % parameters set
    valid_index = cell(CamInfo.RANGE_HEIGHT*CamInfo.RANGE_WIDTH, 1);
    valid_index_size = 0;

    % Fill valid idx
%     valid_index = cell(size(projected_vec));
    for h_pro = 1:ProInfo.RANGE_HEIGHT
        for w_pro = 1:ProInfo.RANGE_WIDTH
            pvec_idx = (h_pro-1)*ProInfo.RANGE_WIDTH+w_pro;
            % h_cam = corres_mat{h_pro,w_pro}(1,1);
            % w_cam = corres_mat{h_pro,w_pro}(1,2);
            A = EpiLine.lineA(h_pro, w_pro);
            B = EpiLine.lineB(h_pro, w_pro);
            M = ParaSet.M(pvec_idx,:);

            projected_x = (M(1)*delta_depth_vec(pvec_idx) + C_set(pvec_idx,1)) ...
                / (M(3)*delta_depth_vec(pvec_idx) + C_set(pvec_idx,3));
            projected_y = -A/B * projected_x + 1/B;
            for dlt_h = -8:8
                for dlt_w = -8:8
                    w_cam = round(projected_x) + dlt_w ...
                        - CamInfo.range_mat(1,1) + 1;
                    h_cam = round(projected_y) + dlt_h ...
                        - CamInfo.range_mat(2,1) + 1;
                    cvec_idx = (h_cam-1)*CamInfo.RANGE_WIDTH + w_cam;
                    if (cvec_idx>=1) && (cvec_idx<=size(valid_index,1))
                        valid_index{cvec_idx,1} = [valid_index{cvec_idx,1}; ...
                            pvec_idx];
                        valid_index_size = valid_index_size + 1;
                    end
                end
            end
        end
    end

    % Fill projected_image
    vecmat_idx = zeros(valid_index_size, 2);
    vecmat_val = zeros(valid_index_size, 1);
    now_idx = 0;
    for cvec_idx = 1:CamInfo.RANGE_HEIGHT*CamInfo.RANGE_WIDTH
        x_cam = ParaSet.coord_cam(cvec_idx,2) + CamInfo.range_mat(1,1) - 1;
        y_cam = ParaSet.coord_cam(cvec_idx,1) + CamInfo.range_mat(2,1) - 1;

        for p_num = 1:size(valid_index{cvec_idx,1},1)
            pvec_idx = valid_index{cvec_idx,1}(p_num,1);
            w_pro = ParaSet.coord_pro(pvec_idx,2);
            h_pro = ParaSet.coord_pro(pvec_idx,1);
            A = EpiLine.lineA(h_pro,w_pro);
            B = EpiLine.lineB(h_pro,w_pro);
            M = ParaSet.M(pvec_idx,:);
            % sigma_x = ParaTable.sigma(pvec_idx,1);
            % sigma_y = ParaTable.sigma(pvec_idx,2);
            color = color_table(pvec_idx);
            sigma_x = sigma_table(pvec_idx,1);
            sigma_y = sigma_table(pvec_idx,2);

            projected_x = (M(1)*delta_depth_vec(pvec_idx) + C_set(pvec_idx,1)) ...
                / (M(3)*delta_depth_vec(pvec_idx) + C_set(pvec_idx,3));
            projected_y = -(A/B) * projected_x + (1/B);
            exp_val = - 1/(2*sigma_table(pvec_idx,1)^2) ...
                * (x_cam - projected_x)^2 ...
                - 1/(2*sigma_table(pvec_idx,2)^2) ...
                * (y_cam - projected_y)^2;

            now_idx = now_idx + 1;
            vecmat_idx(now_idx,:) = [cvec_idx, pvec_idx];
            vecmat_val(now_idx,1) = color ...
                * 1/(2*pi*sigma_x*sigma_y) ...
                * exp(exp_val);
        end
    end
    projected_vecmat = sparse(vecmat_idx(:,1), vecmat_idx(:,2), vecmat_val);
    projected_vecmat(CamInfo.RANGE_HEIGHT*CamInfo.RANGE_WIDTH, ...
        ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH) = 0;
end
