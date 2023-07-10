function [depth_coarse_vec, depth_fine_vec, ...
    corres_points, opt_mat] = fun_InitDepthVec(FilePath, ...
    CamInfo, ...
    ProInfo, ...
    ParaSet)
% Calculate first depth mat

    % Read xpro_mat, ypro_mat, opt_mat
    xpro_mat = load([FilePath.main_file_path, ...
        FilePath.xpro_file_path, ...
        FilePath.xpro_file_name, ...
        num2str(0), ...
        FilePath.pro_file_suffix]);
    ypro_mat = load([FilePath.main_file_path, ...
        FilePath.ypro_file_path, ...
        FilePath.ypro_file_name, ...
        num2str(0), ...
        FilePath.pro_file_suffix]);
    opt_mat = imread([FilePath.main_file_path, ...
        FilePath.optical_path, ...
        FilePath.optical_name, ...
        FilePath.optical_suffix]);
    depth_coarse_vec = zeros(ProInfo.RANGE_C_HEIGHT*ProInfo.RANGE_C_WIDTH, 1);
    depth_fine_vec = zeros(ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH,1);

    % Intersect xpro_mat, ypro_mat
    intersect_range = [CamInfo.range_mat(1,1) - 1, ...
        CamInfo.range_mat(1,2) + 1; ...
        CamInfo.range_mat(2,1) - 1, ...
        CamInfo.range_mat(2,2) + 1];
    for h = intersect_range(2,1):intersect_range(2,2)
        for w = intersect_range(1,1):intersect_range(1,2)
            if xpro_mat(h,w) < 0
                xpro_mat(h,w) = (xpro_mat(h,w-1) + xpro_mat(h,w+1)) / 2;
            end
            if ypro_mat(h,w) < 0
                ypro_mat(h,w) = (ypro_mat(h-1,w) + ypro_mat(h+1,w)) / 2;
            end
        end
    end

    % Find correspondence point
    corres_points = cell(ProInfo.RANGE_HEIGHT, ProInfo.RANGE_WIDTH);
    for h = intersect_range(2,1):intersect_range(2,2)
        for w = intersect_range(1,1):intersect_range(1,2)
            if mod(ProInfo.pix_size,2) == 1
                xpro_int = round(xpro_mat(h,w)+1);
                ypro_int = round(ypro_mat(h,w)+1);
            else
                xpro_int = round(xpro_mat(h,w)+1.5)-0.5;
                ypro_int = round(ypro_mat(h,w)+1.5)-0.5;
            end
            if (xpro_int < ProInfo.range_mat(1,1)) ...
                || (xpro_int > ProInfo.range_mat(1,2)) ...
                || (ypro_int < ProInfo.range_mat(2,1)) ...
                || (ypro_int > ProInfo.range_mat(2,2))
                continue;
            end
            check_num = (ProInfo.pix_size-1) / 2;
            delta_x = xpro_int - ProInfo.range_mat(1,1);
            delta_y = ypro_int - ProInfo.range_mat(2,1);
            if (mod(delta_x,ProInfo.pix_size) == check_num) ...
                && (mod(delta_y,ProInfo.pix_size) == check_num)
                w_i = floor(delta_x) / ProInfo.pix_size + 1;
                h_i = floor(delta_y) / ProInfo.pix_size + 1;
                corres_points{h_i, w_i} = [w, h];
            end
        end
    end

    % Calculate depth_fine mat
    for h = 1:ProInfo.RANGE_HEIGHT
        for w = 1:ProInfo.RANGE_WIDTH
            pvec_idx = (h-1)*ProInfo.RANGE_WIDTH + w;
            if size(corres_points{h,w},1) > 0
                x_c = corres_points{h,w}(1,1);
                M = ParaSet.M(pvec_idx, :);
                D = ParaSet.D(pvec_idx, :);
                depth_fine_vec(pvec_idx,1) = - (D(1)-D(3)*x_c) / (M(1)-M(3)*x_c);
            end
        end
    end

    % Calculate depth_coarse mat
    for h = 1:ProInfo.RANGE_C_HEIGHT
        for w = 1:ProInfo.RANGE_C_WIDTH
            c_pvec_idx = (h-1)*ProInfo.RANGE_C_WIDTH + w;
            h_s = (h-1)*ProInfo.win_size + 1;
            h_e = h*ProInfo.win_size;
            if h_e > ProInfo.RANGE_HEIGHT
                h_e = ProInfo.RANGE_HEIGHT;
            end
            w_s = (w-1)*ProInfo.win_size + 1;
            w_e = w*ProInfo.win_size;
            if w_e > ProInfo.RANGE_WIDTH
                w_e = ProInfo.RANGE_WIDTH;
            end

            sum_num = 0;
            sum_val = 0;
            for h_f = h_s:h_e
                for w_f = w_s:w_e
                    pvec_idx = (h_f-1)*ProInfo.RANGE_C_WIDTH + w_f;
                    if depth_fine_vec(pvec_idx,1) > 0
                        sum_num = sum_num + 1;
                        sum_val = sum_val + depth_fine_vec(pvec_idx,1);
                    end
                end
            end
            if sum_num > 0
                depth_coarse_vec(c_pvec_idx) = sum_val / sum_num;
            end
            for h_f = h_s:h_e
                for w_f = w_s:w_e
                    pvec_idx = (h_f-1)*ProInfo.RANGE_C_WIDTH + w_f;
                    if depth_fine_vec(pvec_idx,1) == 0
                        depth_fine_vec(pvec_idx,1) = depth_coarse_vec(c_pvec_idx);
                    end
                end
            end
        end
    end
end
