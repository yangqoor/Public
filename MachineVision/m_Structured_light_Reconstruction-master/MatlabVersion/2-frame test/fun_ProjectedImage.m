function [projected_vecmat, valid_index] = fun_ProjectedImage(delta_depth_vec, ...
    color_table, ...
    sigma_table, ...
    CamInfo, ...
    ProInfo, ...
    EpiLine, ...
    C_set, ...
    ParaSet)
% Calculate P

    % parameters set
    projected_vecmat = zeros(CamInfo.RANGE_HEIGHT*CamInfo.RANGE_WIDTH, ...
        ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH);
    % valid_vecmat = zeros(CamInfo.RANGE_HEIGHT*CamInfo.RANGE_WIDTH, ...
%         1);
    valid_index = cell(CamInfo.RANGE_HEIGHT*CamInfo.RANGE_WIDTH, 1);

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
            for dlt_h = -6:6
                for dlt_w = -6:6
                    w_cam = round(projected_x) + dlt_w ...
                        - CamInfo.cam_range(1,1) + 1;
                    h_cam = round(projected_y) + dlt_h ...
                        - CamInfo.cam_range(2,1) + 1;
                    cvec_idx = (h_cam-1)*CamInfo.RANGE_WIDTH + w_cam;
                    if (cvec_idx>=1) && (cvec_idx<=size(projected_vecmat,1))
                        valid_index{cvec_idx,1} = [valid_index{cvec_idx,1}; ...
                            pvec_idx];
                        % valid_vecmat(cvec_idx, pvec_idx) = 1;
                    end
                end
            end
        end
    end

    % Fill projected_image
    for c_idx = 1:CamInfo.RANGE_HEIGHT*CamInfo.RANGE_WIDTH
        x_cam = ParaSet.coord_cam(c_idx,2) + CamInfo.cam_range(1,1) - 1;
        y_cam = ParaSet.coord_cam(c_idx,1) + CamInfo.cam_range(2,1) - 1;

        for p_num = 1:size(valid_index{c_idx,1},1)
            p_idx = valid_index{c_idx,1}(p_num,1);
            w_pro = ParaSet.coord_pro(p_idx,2);
            h_pro = ParaSet.coord_pro(p_idx,1);
            A = EpiLine.lineA(h_pro,w_pro);
            B = EpiLine.lineB(h_pro,w_pro);
            M = ParaSet.M(p_idx,:);

            projected_x = (M(1)*delta_depth_vec(p_idx) + C_set(p_idx,1)) ...
                / (M(3)*delta_depth_vec(p_idx) + C_set(p_idx,3));
            projected_y = -(A/B) * projected_x + (1/B);
            exp_val = - 1/(2*sigma_table(p_idx,1)^2) ...
                * (x_cam - projected_x)^2 ...
                - 1/(2*sigma_table(p_idx,2)^2) ...
                * (y_cam - projected_y)^2;
            projected_vecmat(c_idx, p_idx) = color_table(p_idx,1) ...
                * 1/(2*pi*sigma_table(p_idx,1)*sigma_table(p_idx,2)) ...
                * exp(exp_val);
        end
    end
%     [p_idx_set, c_idx_set, ~] = find(valid_vecmat');
%     pro_xy = zeros(size(c_idx_set,1), 2);
%     for coord_idx = 1:size(c_idx_set, 1)
%         c_idx = c_idx_set(coord_idx);
%         x_cam = ParaSet.coord_cam(c_idx,2) + CamInfo.cam_range(1,1) - 1;
%         y_cam = ParaSet.coord_cam(c_idx,1) + CamInfo.cam_range(2,1) - 1;
%
%         p_idx = p_idx_set(coord_idx);
%         w_pro = ParaSet.coord_pro(p_idx,2);
%         h_pro = ParaSet.coord_cam(p_idx,1);
%         A = EpiLine.lineA(h_pro,w_pro);
%         B = EpiLine.lineB(h_pro,w_pro);
%         M = ParaSet.M(p_idx,:);
%
%         projected_x = (M(1)*delta_depth_vec(p_idx) + C_set(p_idx,1)) ...
%             / (M(3)*delta_depth_vec(p_idx) + C_set(p_idx,3));
%         projected_y = -(A/B) * projected_x + (1/B);
%         pro_xy(coord_idx, :) = [x_cam, y_cam];
%         exp_val = - 1/(2*sigma_table(p_idx,1)^2) ...
%             * (x_cam - projected_x)^2 ...
%             - 1/(2*sigma_table(p_idx,2)^2) ...
%             * (y_cam - projected_y)^2;
%         projected_vecmat(c_idx, p_idx) = color_table(p_idx,1) ...
%             * 1/(2*pi*sigma_table(p_idx,1)*sigma_table(p_idx,2)) ...
%             * exp(exp_val);
%     end

%     fprintf('\n');
end
