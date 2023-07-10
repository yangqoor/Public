function [projected_vecmat, valid_index] = fun_ProjectedImage(delta_depth_vec, ...
    ParaTable, ...
    CamInfo, ...
    ProInfo, ...
    EpiLine, ...
    C_set, ...
    ParaSet)
% Calculate P

    % Fill valid idx according to distance
    valid_index = cell(CamInfo.RANGE_HEIGHT*CamInfo.RANGE_WIDTH, 1);
    valid_index_size = 0;
    for h_cam = 1:CamInfo.RANGE_HEIGHT
        for w_cam = 1:CamInfo.RANGE_WIDTH
            cvec_idx = (h_cam-1)*CamInfo.RANGE_WIDTH+w_cam;
            % h_cam = corres_mat{h_pro,w_pro}(1,1);
            % w_cam = corres_mat{h_pro,w_pro}(1,2);
            A = EpiLine.A(h_cam, w_cam);
            B = EpiLine.B(h_cam, w_cam);
            M = ParaSet.M(cvec_idx,:);
            C = C_set(cvec_idx,:);

            projected_x = (M(1)*delta_depth_vec(cvec_idx) + C(1)) ...
                / (M(3)*delta_depth_vec(cvec_idx) + C(3));
            projected_y = -A/B * projected_x + 1/B;

            for dlt_h = -4:1:4
                for dlt_w = -4:1:4
                    w_center = round(projected_x) - ProInfo.range_mat(1,1) + 1;
                    h_center = round(projected_y) - ProInfo.range_mat(2,1) + 1;
                    w_pro = w_center + dlt_w;
                    h_pro = h_center + dlt_h;
                    x_pro = w_pro-1 + ProInfo.range_mat(1,1);
                    y_pro = h_pro-1 + ProInfo.range_mat(2,1);

                    if (h_pro>=1) && (h_pro<=ProInfo.RANGE_HEIGHT) ...
                        && (w_pro>=1) && (w_pro<=ProInfo.RANGE_WIDTH)
                        pvec_idx = (h_pro-1)*ProInfo.RANGE_WIDTH + w_pro;
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
    now_idx = 1;
    for cvec_idx = 1:CamInfo.RANGE_HEIGHT*CamInfo.RANGE_WIDTH
        h_cam = ParaSet.coord_cam(cvec_idx,1);
        w_cam = ParaSet.coord_cam(cvec_idx,2);
        x_cam = w_cam + CamInfo.range_mat(1,1) - 1;
        y_cam = h_cam + CamInfo.range_mat(2,1) - 1;
        A = EpiLine.A(h_cam, w_cam);
        B = EpiLine.B(h_cam, w_cam);
        M = ParaSet.M(cvec_idx,:);
        C = C_set(cvec_idx,:);

        if cvec_idx == 10807
            fprintf('');
        end

        for p_num = 1:size(valid_index{cvec_idx,1},1)
            pvec_idx = valid_index{cvec_idx,1}(p_num,1);
            w_pro = ParaSet.coord_pro(pvec_idx,2);
            h_pro = ParaSet.coord_pro(pvec_idx,1);
            x_pro = (w_pro-1) + ProInfo.range_mat(1,1);
            y_pro = (h_pro-1) + ProInfo.range_mat(2,1);
            Color = ParaTable.color(pvec_idx,1);
            sigma_x = ParaTable.sigma(pvec_idx,1);
            sigma_y = ParaTable.sigma(pvec_idx,2);

            projected_x = (M(1)*delta_depth_vec(cvec_idx) + C(1)) ...
                / (M(3)*delta_depth_vec(cvec_idx) + C(3));
            projected_y = -(A/B) * projected_x + (1/B);

            exp_val = - 1/(2*sigma_x^2) ...
                * (x_pro - projected_x)^2 ...
                - 1/(2*sigma_y^2) ...
                * (y_pro - projected_y)^2;
            vecmat_idx(now_idx,:) = [cvec_idx, pvec_idx];
            vecmat_val(now_idx,1) = Color ...
                * 1/(2*pi*sigma_x*sigma_y) ...
                * exp(exp_val);
            now_idx = now_idx + 1;
        end
    end
    projected_vecmat = sparse(vecmat_idx(:,1), vecmat_idx(:,2), vecmat_val);
    projected_vecmat(CamInfo.RANGE_HEIGHT*CamInfo.RANGE_WIDTH, ...
        ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH) = 0;
end
