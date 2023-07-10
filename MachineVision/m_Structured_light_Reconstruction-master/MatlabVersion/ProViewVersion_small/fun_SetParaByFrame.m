function [color_table, sigma_table, C_set] = fun_SetParaByFrame(cam_vec, ...
    depth_vec, ...
    EpiLine, ...
    CamInfo, ...
    ProInfo, ...
    ParaSet)
% Fill color & sigma parameter from t-1 information

    % Set output parameters
    color_table = zeros(ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH,1);
    sigma_table = zeros(ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH,2);
    C_set = zeros(ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH,3);

    for pvec_idx = 1:ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH
        h_pro = ParaSet.coord_pro(pvec_idx,1);
        w_pro = ParaSet.coord_pro(pvec_idx,2);
        depth = depth_vec(pvec_idx);
        M = ParaSet.M(pvec_idx,:);
        D = ParaSet.D(pvec_idx,:);
        A = EpiLine.lineA(h_pro,w_pro);
        B = EpiLine.lineB(h_pro,w_pro);

        projected_x = (M(1)*depth + D(1)) / (M(3)*depth + D(3));
        projected_y = -A/B * projected_x + 1/B;
        x_cam = round(projected_x);
        y_cam = round(projected_y);
        h_cam = y_cam - CamInfo.range_mat(2,1) + 1;
        w_cam = x_cam - CamInfo.range_mat(1,1) + 1;
        cvec_idx = (h_cam-1)*CamInfo.RANGE_WIDTH + w_cam;

%         sigma_table(pvec_idx,:) = 2;
% %         fprintf('x_cam=%d,y_cam=%d,h_cam=%d,w_cam=%d,cvec_idx=%d\n', x_cam,y_cam,h_cam,w_cam,cvec_idx);
%         color_table(pvec_idx,1) = (cam_vec(cvec_idx)-40) ...
%             * 2 * pi * sigma_table(pvec_idx,1) * sigma_table(pvec_idx,2);
        C_set(pvec_idx,:) = M*depth + D;
    end

end
