function [show_mat] = fun_DrawDeltaCenterPoint(backgd_vec, ...
    depth_vec, ...
    delta_depth_vec, ...
    CamInfo, ...
    ProInfo, ...
    EpiLine, ...
    ParaSet)
% draw center point on gived mat from depth vec

    % set parameter
    backgd_mat = reshape(backgd_vec, ...
        CamInfo.RANGE_WIDTH, CamInfo.RANGE_HEIGHT)';
    show_mat = zeros(CamInfo.RANGE_HEIGHT, CamInfo.RANGE_WIDTH, 3);
    show_mat(:,:,1) = backgd_mat;
    show_mat(:,:,2) = show_mat(:,:,1);
    show_mat(:,:,3) = show_mat(:,:,1);

    % reproject & draw
    for pvec_idx = 1:ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH
        h_pro = ParaSet.coord_pro(pvec_idx,1);
        w_pro = ParaSet.coord_pro(pvec_idx,2);
        x_pro = (w_pro-1)*ProInfo.pix_size + ProInfo.range_mat(1,1);
        y_pro = (h_pro-1)*ProInfo.pix_size + ProInfo.range_mat(2,1);
        depth = depth_vec(pvec_idx);
        new_depth = depth_vec(pvec_idx) + delta_depth_vec(pvec_idx);

        M = ParaSet.M(pvec_idx,:);
        D = ParaSet.D(pvec_idx,:);
        A = EpiLine.lineA(h_pro,w_pro);
        B = EpiLine.lineB(h_pro,w_pro);
        x_cam_old = (M(1)*depth + D(1)) / (M(3)*depth + D(3));
        y_cam_old = -A/B * x_cam_old + 1/B;
        x_cam_new = (M(1)*new_depth + D(1)) / (M(3)*new_depth + D(3));
        y_cam_new = -A/B * x_cam_new + 1/B;

        w_cam_old = round(x_cam_old) - CamInfo.range_mat(1,1) + 1;
        h_cam_old = round(y_cam_old) - CamInfo.range_mat(2,1) + 1;
        w_cam_new = round(x_cam_new) - CamInfo.range_mat(1,1) + 1;
        h_cam_new = round(y_cam_new) - CamInfo.range_mat(2,1) + 1;
        if (w_cam_old == w_cam_new)
            show_mat(h_cam_old,w_cam_old,:) = 0.0;
            show_mat(h_cam_old,w_cam_old,1:2) = 255.0;
        else
            show_mat(h_cam_old,w_cam_old,:) = 0.0;
            show_mat(h_cam_old,w_cam_old,1) = 255.0;
            show_mat(h_cam_new,w_cam_new,:) = 0.0;
            show_mat(h_cam_new,w_cam_new,2) = 255.0;
        end
    end

end
