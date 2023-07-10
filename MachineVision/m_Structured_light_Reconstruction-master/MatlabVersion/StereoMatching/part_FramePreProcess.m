% if frm_idx == 2
%     % Set h_scale
%     h_scale_mats{frm_idx-1, 1} = ones(CamInfo.R_HEIGHT, CamInfo.R_WIDTH) ...
%         * (2*CamInfo.win_rad+1);
%     for w_cam = 1:CamInfo.R_WIDTH
%         for h_cam = CamInfo.win_rad+1:CamInfo.R_HEIGHT-CamInfo.win_rad
%             h_pro_up = y_pro_mats{frm_idx-1,1}(h_cam-CamInfo.win_rad,w_cam);
%             h_pro_dn = y_pro_mats{frm_idx-1,1}(h_cam+CamInfo.win_rad,w_cam);
%             h_scale_mats{frm_idx-1,1}(h_cam,w_cam) = (h_pro_dn - h_pro_up)/2;
%         end
%         h_scale_mats{frm_idx-1,1}(1:CamInfo.win_rad,w_cam) ...
%             = h_scale_mats{frm_idx-1,1}(CamInfo.win_rad+1,w_cam);
%         h_scale_mats{frm_idx-1,1}(CamInfo.R_HEIGHT-CamInfo.win_rad+1:end, w_cam) ...
%             = h_scale_mats{frm_idx-1,1}(CamInfo.R_HEIGHT-CamInfo.win_rad,w_cam);
%     end
% 
%     % Set w_scale
%     w_scale_mats{frm_idx-1, 1} = ones(CamInfo.R_HEIGHT, CamInfo.R_WIDTH) ...
%         * (2*CamInfo.win_rad+1);
%     for h_cam = 1:CamInfo.R_HEIGHT
%         for w_cam = CamInfo.win_rad+1:CamInfo.R_WIDTH-CamInfo.win_rad
%             w_pro_lf = x_pro_mats{frm_idx-1,1}(h_cam,w_cam-CamInfo.win_rad);
%             w_pro_rt = x_pro_mats{frm_idx-1,1}(h_cam,w_cam+CamInfo.win_rad);
%             w_scale_mats{frm_idx-1,1}(h_cam,w_cam) = (w_pro_rt - w_pro_lf)/2;
%         end
%         w_scale_mats{frm_idx-1,1}(h_cam,1:CamInfo.win_rad) ...
%             = h_scale_mats{frm_idx-1,1}(h_cam,CamInfo.win_rad+1);
%         w_scale_mats{frm_idx-1,1}(h_cam,CamInfo.R_WIDTH-CamInfo.win_rad+1:end) ...
%             = h_scale_mats{frm_idx-1,1}(h_cam,CamInfo.R_WIDTH-CamInfo.win_rad);
%     end
% end

% Initialize other
x_pro_mats{frm_idx,1} = zeros(CamInfo.R_HEIGHT, CamInfo.R_WIDTH);
y_pro_mats{frm_idx,1} = zeros(CamInfo.R_HEIGHT, CamInfo.R_WIDTH);
depth_mats{frm_idx,1} = zeros(CamInfo.R_HEIGHT, CamInfo.R_WIDTH);
match_res{frm_idx,1} = cell(CamInfo.R_HEIGHT, CamInfo.R_WIDTH);
