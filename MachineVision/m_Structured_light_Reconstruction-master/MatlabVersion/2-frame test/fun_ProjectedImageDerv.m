function [projected_derv] = fun_ProjectedImageDerv(projected_vecmat, ...
    valid_index, ...
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
    projected_derv = zeros(CamInfo.RANGE_HEIGHT*CamInfo.RANGE_WIDTH, ...
        ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH);

    % Calculate derv P
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
            
            mul_val = (M(1)*C_set(p_idx,3) - M(3)*C_set(p_idx,1)) ...
                / (M(3)*delta_depth_vec(p_idx) + C_set(p_idx,3)).^2 ...
                * ((1/sigma_table(p_idx,1)^2) * (x_cam - projected_x) ...
                + (1/sigma_table(p_idx,2)^2) * (y_cam - projected_y) * (-A/B));
            projected_derv(c_idx,p_idx) = mul_val*projected_vecmat(c_idx,p_idx);
        end
    end
%     [c_idx_set, p_idx_set, valid_vec] = find(valid_vecmat);
%     for c_idx = c_idx_set
%         x_cam = ParaSet.coord_cam(c_idx,2) + CamInfo.cam_range(1,1) - 1;
%         y_cam = ParaSet.coord_cam(c_idx,1) + CamInfo.cam_range(2,1) - 1;
%         for p_idx = p_idx_set
%             w_pro = ParaSet.coord_pro(k,2);
%             h_pro = ParaSet.coord_cam(k,1);
%             A = EpiLine.lineA(h_pro,w_pro);
%             B = EpiLine.lineB(h_pro,w_pro);
%             M = ParaSet.M(k,:);
% 
%             projected_x = (M(1)*delta_depth_vec(k) + C_set(k,1)) ...
%                 / (M(3)*delta_depth_vec(k) + C_set(k,3));
%             projected_y = -(A/B) * projected_x + (1/B);
% 
%             mul_val = (M(1)*C_set(k,3) - M(3)*C_set(k,1)) ...
%                 / (M(3)*depth_vec(k) + C_set(k,3)).^2 ...
%                 * ((1/sigma_table(k,1)^2) * (x_cam - projected_x) ...
%                 + (1/sigma_table(k,2)^2) * (y_cam - projected_y) * (-A/B));
%             projected_derv(c_idx,p_idx) = mul_val*projected_vecmat(c_idx,p_idx);
%         end
%     end

%     fprintf('\n');

end
