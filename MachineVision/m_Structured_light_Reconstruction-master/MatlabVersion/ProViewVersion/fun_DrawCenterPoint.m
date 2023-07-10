function [show_mat] = fun_DrawCenterPoint(background_vec, ...
    depth_vec, ...
    CamInfo, ...
    ProInfo, ...
    EpiLine, ...
    ParaSet)
% draw center point on gived mat from depth vec

    % set parameter
    background_mat = reshape(background_vec, ...
        CamInfo.RANGE_WIDTH, CamInfo.RANGE_HEIGHT)';
%     background_mat = background_vec;
    show_mat = zeros(CamInfo.RANGE_HEIGHT, CamInfo.RANGE_WIDTH, 3);
    show_mat(:,:,1) = background_mat;
    show_mat(:,:,2) = show_mat(:,:,1);
    show_mat(:,:,3) = show_mat(:,:,1);

    % reproject
    for pvec_idx = 1:ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH
        h_pro = ParaSet.coord_pro(pvec_idx,1);
        w_pro = ParaSet.coord_pro(pvec_idx,2);
        x_pro = (w_pro-1)*3 + ProInfo.pro_range(1,1);
        y_pro = (h_pro-1)*3 + ProInfo.pro_range(2,1);
        depth = depth_vec(pvec_idx);

        M = ParaSet.M(pvec_idx,:);
        D = ParaSet.D(pvec_idx,:);
        A = EpiLine.lineA(h_pro,w_pro);
        B = EpiLine.lineB(h_pro,w_pro);
        x_cam = (M(1)*depth + D(1)) / (M(3)*depth + D(3));
        y_cam = -A/B * x_cam + 1/B;
        % y_cam = (M(2)*depth + D(2)) / (M(3)*depth + D(3));
        h_cam = round(y_cam) - CamInfo.cam_range(2,1) + 1;
        w_cam = round(x_cam) - CamInfo.cam_range(1,1) + 1;

        show_mat(h_cam,w_cam,:) = 0.0;
        show_mat(h_cam,w_cam,3) = 255.0;
    end

end
