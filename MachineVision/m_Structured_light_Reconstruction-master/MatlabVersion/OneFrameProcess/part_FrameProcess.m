% Compare & set index
for h_cam = CamInfo.win_rad+1:CamInfo.R_HEIGHT-CamInfo.win_rad
    for w_cam = CamInfo.win_rad+1:CamInfo.R_WIDTH-CamInfo.win_rad
        % extract raw_cam_patch
        h_sta = h_cam - CamInfo.win_rad;
        h_end = h_cam + CamInfo.win_rad;
        w_sta = w_cam - CamInfo.win_rad;
        w_end = w_cam + CamInfo.win_rad;
        raw_cam_patch = cam_mats{frm_idx,1}(h_sta:h_end, w_sta:w_end);

        % convert to cam_patch
        cam_max_val = max(max(raw_cam_patch));
        cam_min_val = min(min(raw_cam_patch));
        if cam_max_val - cam_min_val < ParaSet.lumi_thred
            continue;
        end
        cam_patch = (raw_cam_patch-cam_min_val)/(cam_max_val-cam_min_val);
        rsz_cam_patch = imresize(cam_patch, ...
            [2*pro_rad+1,2*pro_rad+1]);

        % Match
        cvec_idx = (h_cam-1)*CamInfo.R_WIDTH + w_cam;
        match_min_val = 999999;
        match_min_idx = [];
        for x_pro = ProInfo.range_mat(1,1):ProInfo.range_mat(1,2)
            A = EpiLine.lineA(h_cam,w_cam);
            B = EpiLine.lineB(h_cam,w_cam);
            if B == 0
                continue;
            end
            y_pro = round((-A/B)*(x_pro-1) + (1/B) + 1);

            raw_pro_patch = double(pattern(y_pro-pro_rad:y_pro+pro_rad, ...
                x_pro-pro_rad:x_pro+pro_rad));
            pro_max_val = pattern_max_val(y_pro,x_pro);
            pro_min_val = pattern_min_val(y_pro,x_pro);
            if pro_max_val - pro_min_val < ParaSet.lumi_thred
                continue;
            end
            pro_patch = (raw_pro_patch-pro_min_val)/(pro_max_val-pro_min_val);

            error_value = sum(sum((rsz_cam_patch-pro_patch).^2));
            % imshow(imresize([rsz_cam_patch;pro_patch], 10));
            if error_value < match_min_val
                match_min_val = error_value;
                match_min_idx = [x_pro,y_pro];
            end
        end

        if size(match_min_idx,1) == 0
            continue;
        end
        match_res{frm_idx,1}{h_cam,w_cam} = [match_min_idx, match_min_val];
        x_pro_mats{frm_idx,1}(h_cam,w_cam) = match_min_idx(1);
        y_pro_mats{frm_idx,1}(h_cam,w_cam) = match_min_idx(2);
    end
    if mod(h_cam,10) == 0
        fprintf('.');
    end
end
% fprintf('\n');
