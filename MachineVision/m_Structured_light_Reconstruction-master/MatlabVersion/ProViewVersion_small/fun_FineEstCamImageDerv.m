function [cam_est_derv] = fun_FineEstCamImageDerv(cam_est_vecmat, ...
    depth_fine_vec, ...
    ParaTable, ...
    CamInfo, ...
    ProInfo, ...
    EpiLine, ...
    ParaSet)
% Calculate cam_est_derv

    valid_index_size = (ParaSet.lum_radius*2+1)^2 ...
        * ProInfo.RANGE_HEIGHT * ProInfo.RANGE_WIDTH;
    derv_idx = ones(valid_index_size, 2);
    derv_val = zeros(valid_index_size, 1);
    now_idx = 0;

    for h_pro = 1:ProInfo.RANGE_HEIGHT
        for w_pro = 1:ProInfo.RANGE_WIDTH
            pvec_idx = (h_pro-1)*ProInfo.RANGE_WIDTH+w_pro;

            A = EpiLine.lineA(h_pro, w_pro);
            B = EpiLine.lineB(h_pro, w_pro);
            M = ParaSet.M(pvec_idx,:);
            D = ParaSet.D(pvec_idx,:);

            depth = depth_fine_vec(pvec_idx,1);
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
                        mul_val = (M(1)*D(3) - M(3)*D(1)) ...
                            / (M(3)*depth + D(3))^2 ...
                            * ((1/sigma_x^2) * (x_cam-projected_x) ...
                            + (1/sigma_y^2) * (y_cam-projected_y) * (-A/B));

                        derv_idx(now_idx,:) = [cvec_idx,pvec_idx];
                        derv_val(now_idx,1) = mul_val*cam_est_vecmat(cvec_idx,pvec_idx);
                    end
                end
            end
        end
    end

    % Fill projected_image
    cam_est_derv = sparse(derv_idx(:,1), derv_idx(:,2), derv_val);
    cam_est_derv(CamInfo.RANGE_HEIGHT*CamInfo.RANGE_WIDTH, ...
        ProInfo.RANGE_C_HEIGHT*ProInfo.RANGE_C_WIDTH) = 0;
end
