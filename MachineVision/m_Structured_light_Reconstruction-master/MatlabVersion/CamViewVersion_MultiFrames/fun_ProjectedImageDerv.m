function [projected_derv_vecmats] = fun_ProjectedImageDerv(projected_vecmats, ...
    valid_indexs, ...
    depth_vecs, ...
    ParaTable, ...
    CamInfo, ...
    ProInfo, ...
    EpiLine, ...
    ParaSet)
%Calculate P'

    % parameters set
    flow_size = size(projected_vecmats,1);
    projected_derv_vecmats = cell(flow_size,1);
    for flw_idx = 1:flow_size
        projected_derv_vec = zeros(CamInfo.RANGE_HEIGHT*CamInfo.RANGE_WIDTH,1);
        % Calculate derv P
        for cvec_idx = 1:CamInfo.RANGE_HEIGHT*CamInfo.RANGE_WIDTH
            h_cam = ParaSet.coord_cam(cvec_idx,1);
            w_cam = ParaSet.coord_cam(cvec_idx,2);
            A = EpiLine.A(h_cam, w_cam);
            B = EpiLine.B(h_cam, w_cam);
            M = ParaSet.M(cvec_idx,:);
            D = ParaSet.D(cvec_idx,:);
            depth = depth_vecs{flw_idx,1}(cvec_idx);
            projected_x = (M(1)*depth + D(1)) / (M(3)*depth + D(3));
            projected_y = -(A/B) * projected_x + (1/B);

            for p_num = 1:size(valid_indexs{flw_idx,1}{cvec_idx,1},1)
                pvec_idx = valid_indexs{flw_idx,1}{cvec_idx,1}(p_num,1);
                w_pro = ParaSet.coord_pro(pvec_idx,2);
                h_pro = ParaSet.coord_pro(pvec_idx,1);
                x_pro = (w_pro-1) + ProInfo.range_mat(1,1);
                y_pro = (h_pro-1) + ProInfo.range_mat(2,1);
                sigma_x = ParaTable.sigma(pvec_idx,1);
                sigma_y = ParaTable.sigma(pvec_idx,2);

                mul_val = (M(1)*D(3)-M(3)*D(1)) / (M(3)*depth+D(3)).^2 ...
                    * ((1/sigma_x^2) * (x_pro - projected_x) ...
                    + (1/sigma_y^2) * (y_pro - projected_y) * (-A/B));
                projected_derv_vec(cvec_idx) = projected_derv_vec(cvec_idx) ...
                    + mul_val * projected_vecmats{flw_idx,1}(cvec_idx,pvec_idx);
            end
        end

        % derv
        projected_derv_vecmats{flw_idx,1} = sparse(diag(projected_derv_vec));
    end
end
