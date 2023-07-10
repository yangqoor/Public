function [projected_derv] = fun_ProjectedImageDerv(projected_vecmat, ...
    valid_index, ...
    delta_depth_vec, ...
    ParaTable, ...
    CamInfo, ...
    ProInfo, ...
    EpiLine, ...
    C_set, ...
    ParaSet)
%Calculate P'

    % parameters set
    projected_derv_vec = zeros(CamInfo.RANGE_HEIGHT*CamInfo.RANGE_WIDTH,1);

    % Calculate derv P
    for cvec_idx = 1:CamInfo.RANGE_HEIGHT*CamInfo.RANGE_WIDTH
        h_cam = ParaSet.coord_cam(cvec_idx,1);
        w_cam = ParaSet.coord_cam(cvec_idx,2);
        x_cam = w_cam + CamInfo.range_mat(1,1) - 1;
        y_cam = h_cam + CamInfo.range_mat(2,1) - 1;
        A = EpiLine.A(h_cam, w_cam);
        B = EpiLine.B(h_cam, w_cam);
        M = ParaSet.M(cvec_idx,:);
        C = C_set(cvec_idx,:);

        for p_num = 1:size(valid_index{cvec_idx,1},1)
            pvec_idx = valid_index{cvec_idx,1}(p_num,1);
            w_pro = ParaSet.coord_pro(pvec_idx,2);
            h_pro = ParaSet.coord_pro(pvec_idx,1);
            x_pro = (w_pro-1) + ProInfo.range_mat(1,1);
            y_pro = (h_pro-1) + ProInfo.range_mat(2,1);
            sigma_x = ParaTable.sigma(pvec_idx,1);
            sigma_y = ParaTable.sigma(pvec_idx,2);

            projected_x = (M(1)*delta_depth_vec(cvec_idx) + C(1)) ...
                / (M(3)*delta_depth_vec(cvec_idx) + C(3));
            projected_y = -(A/B) * projected_x + (1/B);

            mul_val = (M(1)*C(3) - M(3)*C(1)) ...
                / (M(3)*delta_depth_vec(cvec_idx) + C(3)).^2 ...
                * ((1/sigma_x^2) * (x_pro - projected_x) ...
                + (1/sigma_y^2) * (y_pro - projected_y) * (-A/B));
            projected_derv_vec(cvec_idx) = projected_derv_vec(cvec_idx) ...
                + mul_val * projected_vecmat(cvec_idx,pvec_idx);
        end
    end

    % derv
    projected_derv = sparse(diag(projected_derv_vec));
    projected_derv(CamInfo.RANGE_HEIGHT*CamInfo.RANGE_WIDTH, ...
        ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH) = 0;
end
