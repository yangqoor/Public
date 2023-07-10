function [projected_derv] = fun_ProjectedImageDerv(projected_vecmat, ...
    valid_index, ...
    valid_index_size, ...
    delta_depth_vec, ...
    color_table, ...
    sigma_table, ...
    CamInfo, ...
    ProInfo, ...
    EpiLine, ...
    C_set, ...
    ParaSet)
%Calculate P'

    % parameters set
    derv_idx = zeros(valid_index_size, 2);
    derv_val = zeros(valid_index_size, 1);
    now_idx = 0;

    % Calculate derv P
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

            projected_x = (M(1)*delta_depth_vec(pvec_idx) + C_set(pvec_idx,1)) ...
                / (M(3)*delta_depth_vec(pvec_idx) + C_set(pvec_idx,3));
            projected_y = -(A/B) * projected_x + (1/B);

            mul_val = (M(1)*C_set(pvec_idx,3) - M(3)*C_set(pvec_idx,1)) ...
                / (M(3)*delta_depth_vec(pvec_idx) + C_set(pvec_idx,3)).^2 ...
                * ((1/sigma_table(pvec_idx,1)^2) * (x_cam - projected_x) ...
                + (1/sigma_table(pvec_idx,2)^2) * (y_cam - projected_y) * (-A/B));
            % projected_derv(cvec_idx,pvec_idx) = mul_val*projected_vecmat(cvec_idx,pvec_idx);

            now_idx = now_idx + 1;
            derv_idx(now_idx,:) = [cvec_idx, pvec_idx];
            derv_val(now_idx,1) = mul_val*projected_vecmat(cvec_idx,pvec_idx);
        end
    end
    projected_derv = sparse(derv_idx(:,1), derv_idx(:,2), derv_val);
    projected_derv(CamInfo.RANGE_HEIGHT*CamInfo.RANGE_WIDTH, ...
        ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH) = 0;
end
