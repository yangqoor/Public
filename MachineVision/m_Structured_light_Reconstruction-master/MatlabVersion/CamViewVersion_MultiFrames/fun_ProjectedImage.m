function [projected_vecmats, valid_indexs] = fun_ProjectedImage(depth_vecs, ...
    ParaTable, ...
    CamInfo, ...
    ProInfo, ...
    EpiLine, ...
    ParaSet)
% Calculate I_est

    % Fill valid idx according to distance
    flow_size = size(depth_vecs,1);
    valid_indexs = cell(flow_size,1);
    projected_vecmats = cell(flow_size,1);

    for flw_idx = 1:flow_size
        % Fill valid_index
        valid_indexs{flw_idx,1} = cell(CamInfo.RANGE_HEIGHT*CamInfo.RANGE_WIDTH, 1);
        valid_index_size = 0;
        for h_cam = 1:CamInfo.RANGE_HEIGHT
            for w_cam = 1:CamInfo.RANGE_WIDTH
                cvec_idx = (h_cam-1)*CamInfo.RANGE_WIDTH+w_cam;
                A = EpiLine.A(h_cam, w_cam);
                B = EpiLine.B(h_cam, w_cam);
                M = ParaSet.M(cvec_idx,:);
                D = ParaSet.D(cvec_idx,:);
                depth = depth_vecs{flw_idx,1}(cvec_idx);
                projected_x = (M(1)*depth + D(1)) ...
                    / (M(3)*depth + D(3));
                projected_y = -A/B * projected_x + 1/B;

                for dlt_h = -4:1:4
                    for dlt_w = -4:1:4
                        w_center = round(projected_x) - ProInfo.range_mat(1,1) + 1;
                        h_center = round(projected_y) - ProInfo.range_mat(2,1) + 1;
                        w_pro = w_center + dlt_w;
                        h_pro = h_center + dlt_h;

                        if (h_pro>=1) && (h_pro<=ProInfo.RANGE_HEIGHT) ...
                            && (w_pro>=1) && (w_pro<=ProInfo.RANGE_WIDTH)
                            pvec_idx = (h_pro-1)*ProInfo.RANGE_WIDTH + w_pro;
                            valid_indexs{flw_idx,1}{cvec_idx,1} ...
                                = [valid_indexs{flw_idx,1}{cvec_idx,1}; ...
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
            A = EpiLine.A(h_cam, w_cam);
            B = EpiLine.B(h_cam, w_cam);
            M = ParaSet.M(cvec_idx,:);
            D = ParaSet.D(cvec_idx,:);
            depth = depth_vecs{flw_idx,1}(cvec_idx);
            projected_x = (M(1)*depth + D(1)) ...
                / (M(3)*depth + D(3));
            projected_y = -A/B * projected_x + 1/B;

            if cvec_idx == 10807
                fprintf('');
            end

            for p_num = 1:size(valid_indexs{flw_idx,1}{cvec_idx,1},1)
                pvec_idx = valid_indexs{flw_idx,1}{cvec_idx,1}(p_num,1);
                w_pro = ParaSet.coord_pro(pvec_idx,2);
                h_pro = ParaSet.coord_pro(pvec_idx,1);
                x_pro = (w_pro-1) + ProInfo.range_mat(1,1);
                y_pro = (h_pro-1) + ProInfo.range_mat(2,1);
                color = ParaTable.color(pvec_idx,1);
                sigma_x = ParaTable.sigma(pvec_idx,1);
                sigma_y = ParaTable.sigma(pvec_idx,2);

                exp_val = - 1/(2*sigma_x^2) ...
                    * (x_pro - projected_x)^2 ...
                    - 1/(2*sigma_y^2) ...
                    * (y_pro - projected_y)^2;
                vecmat_idx(now_idx,:) = [cvec_idx, pvec_idx];
                vecmat_val(now_idx,1) = color ...
                    * 1/(2*pi*sigma_x*sigma_y) ...
                    * exp(exp_val);
                now_idx = now_idx + 1;
            end
        end
        projected_vecmats{flw_idx,1} ...
            = sparse(vecmat_idx(:,1), vecmat_idx(:,2), vecmat_val);
        projected_vecmats{flw_idx,1}(CamInfo.RANGE_HEIGHT*CamInfo.RANGE_WIDTH, ...
            ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH) = 0;
    end
end
