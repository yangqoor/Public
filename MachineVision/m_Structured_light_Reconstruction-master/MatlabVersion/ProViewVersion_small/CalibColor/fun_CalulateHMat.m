function [H_mat] = fun_CalculateHMat(FilePath, ...
    frame_idx, ...
    sigma_val, ...
    CamInfo, ...
    ProInfo)

% Calculate H mat from xpro & ypro_mat

    % Load information
    xpro_mat = load([FilePath.main_file_path, ...
        FilePath.xpro_file_path, ...
        FilePath.xpro_file_name, ...
        num2str(frame_idx), ...
        FilePath.pro_file_suffix]);
    ypro_mat = load([FilePath.main_file_path, ...
        FilePath.ypro_file_path, ...
        FilePath.ypro_file_name, ...
        num2str(0), ...
        FilePath.pro_file_suffix]);

    % Check searching area
    cam_range_mat = [CamInfo.WIDTH, 1; CamInfo.HEIGHT, 1];
    for h = 1:CamInfo.HEIGHT
        for w = 1:CamInfo.WIDTH
            x_pro = xpro_mat(h,w) + 1;
            y_pro = ypro_mat(h,w) + 1;
            if (x_pro >= ProInfo.range_mat(1,1)-4) ...
                && (x_pro <= ProInfo.range_mat(1,2)-4) ...
                && (y_pro >= ProInfo.range_mat(2,1)-4) ...
                && (y_pro <= ProInfo.range_mat(2,2)-4)
                if x_pro < cam_range_mat(1,1)
                    cam_range_mat(1,1) = x_pro;
                end
                if x_pro > cam_range_mat(1,2)
                    cam_range_mat(1,2) = x_pro;
                if y_pro > cam_range_mat(2,1)
                    cam_range_mat(2,1) = y_pro;
                end
                if y_pro < cam_range_mat(2,2)
                    cam_range_mat(2,2) = y_pro;
                end
            end
        end
    end

    % Intersect
    for w = cam_range_mat(1,1):cam_range_mat(1,2)
        for h = cam_range_mat(2,1):cam_range_mat(2,2)
            if xpro_mat(h,w) < 0
                xpro_mat(h,w) = (xpro_mat(h,w-1) + xpro_mat(h,w+1)) / 2;
            end
            if ypro_mat(h,w) < 0
                ypro_mat(h,w) = (ypro_mat(h-1,w) + ypro_mat(h+1,w)) / 2;
            end
        end
    end

    % Fill Neighbor valid points
    cr_height = cam_range_mat(2,2) - cam_range_mat(2,1) + 1;
    cr_width = cam_range_mat(1,2) - cam_range_mat(1,1) + 1;
    valid_index = cell(cr_height*cr_width, 3);
    for h_cam = 1:cr_height
        for w_cam = 1:cr_width
            x_cam = w_cam + cam_range_mat(1,1) - 1;
            y_cam = h_cam + cam_range_mat(2,1) - 1;
            cvec_idx = (h_cam-1)*cr_width + w_cam;
            projected_x = xpro_mat(y_cam,x_cam) + 1;
            projected_y = ypro_mat(y_cam,x_cam) + 1;
            valid_index{cvec_idx,1} = [projected_x, projected_y];

            for dlt_h = -4:1:4
                for dlt_w = -4:1:4
                    w_center = round((projected_x-ProInfo.range_mat(1,1))/3+1);
                    h_center = round((projected_y-ProInfo.range_mat(2,1))/3+1);
                    w_pro = w_center + dlt_w;
                    h_pro = h_center + dlt_h;
                    x_pro = (w_pro-1)*3 + ProInfo.range_mat(1,1);
                    y_pro = (h_pro-1)*3 + ProInfo.range_mat(2,1);

                    if (h_pro>=1) && (h_pro<=ProInfo.RANGE_HEIGHT) ...
                        && (w_pro>=1) && (w_pro<=ProInfo.RANGE_WIDTH)
                        pvec_idx = (h_pro-1)*ProInfo.RANGE_WIDTH + w_pro;
                        valid_index{cvec_idx,2} = [valid_index{cvec_idx,2}; ...
                            [x_pro, y_pro]];
                        valid_index{cvec_idx,3} = [valid_index{cvec_idx,3}; ...
                            pvec_idx];
                    end
                end
            end
        end
    end

    % Fill mat H
    H_mat = zeros(cr_height*cr_width, ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH+1);
    H_mat(:,end) = 1;
    for cvec_idx = 1:cr_height*cr_width
        projected_x = valid_index{cvec_idx,1}(1);
        projected_y = valid_index{cvec_idx,1}(2);
        for p_num = 1:size(valid_index{cvec_idx,2},1)
            pvec_idx = valid_index{cvec_idx,3}(p_num);
            x_pro = valid_index{cvec_idx,2}(p_num,1);
            y_pro = valid_index{cvec_idx,2}(p_num,2);
            sigma_x = sigma_val(1);
            sigma_y = sigma_val(2);
            exp_val = - 1/(2*sigma_x^2) * (x_pro - projected_x)^2 ...
                - 1/(2*sigma_y^2) * (y_pro - projected_y)^2;
            H_mat(cvec_idx,pvec_idx) = 1/(2*pi*sigma_x*sigma_y) ...
                * exp(exp_val);
        end
    end

end
