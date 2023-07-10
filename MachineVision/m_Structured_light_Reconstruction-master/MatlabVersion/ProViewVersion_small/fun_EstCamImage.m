function [cam_est_vecmat] = fun_EstCamImage(depth_fine_vec, ...
    ParaTable, ...
    CamInfo, ...
    ProInfo, ...
    EpiLine, ...
    ParaSet)
% Calculate P

    % Fill valid idx
    valid_index_size = (ParaSet.lum_radius*2+1)^2 ...
        * ProInfo.RANGE_HEIGHT * ProInfo.RANGE_WIDTH;
    vecmat_idx = ones(valid_index_size, 2);
    vecmat_val = zeros(valid_index_size, 1);
    now_idx = 0;
    for h_pro = 1:ProInfo.RANGE_HEIGHT
        for w_pro = 1:ProInfo.RANGE_WIDTH
            pvec_idx = (h_pro-1)*ProInfo.RANGE_WIDTH+w_pro;
            A = EpiLine.lineA(h_pro, w_pro);
            B = EpiLine.lineB(h_pro, w_pro);
            M = ParaSet.M(pvec_idx,:);
            D = ParaSet.D(pvec_idx,:);
            depth = depth_fine_vec(pvec_idx,1);
            color = ParaTable.color(pvec_idx);
            sigma_x = ParaTable.sigma(pvec_idx,1);
            sigma_y = ParaTable.sigma(pvec_idx,2);

            projected_x = (M(1)*depth + D(1)) / (M(3)*depth + D(3));
            projected_y = -A/B * projected_x + 1/B;

            for dlt_h = -ParaSet.lum_radius:ParaSet.lum_radius
                for dlt_w = -ParaSet.lum_radius:ParaSet.lum_radius
                    now_idx = now_idx + 1;
                    x_cam = round(projected_x) + dlt_w;
                    y_cam = round(projected_y) + dlt_h;
                    w_cam = x_cam+1 - CamInfo.range_mat(1,1) + 1;
                    h_cam = y_cam+1 - CamInfo.range_mat(2,1) + 1;
                    cvec_idx = (h_cam-1)*CamInfo.RANGE_WIDTH + w_cam;

                    if (cvec_idx<=CamInfo.RANGE_HEIGHT*CamInfo.RANGE_WIDTH) ...
                        && (cvec_idx>=1)
                        exp_val = - 1/(2*sigma_x^2) ...
                            * (x_cam - projected_x)^2 ...
                            - 1/(2*sigma_y^2) ...
                            * (y_cam - projected_y)^2;
                        vecmat_idx(now_idx,:) = [cvec_idx,pvec_idx];
                        vecmat_val(now_idx,1) = color ...
                            * 1/(2*pi*sigma_x*sigma_y) ...
                            * exp(exp_val);
                    end
                end
            end
        end
    end

    % Fill projected_image
    cam_est_vecmat = sparse(vecmat_idx(:,1), vecmat_idx(:,2), vecmat_val);
    cam_est_vecmat(CamInfo.RANGE_HEIGHT*CamInfo.RANGE_WIDTH, ...
        ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH) = 0;
end
