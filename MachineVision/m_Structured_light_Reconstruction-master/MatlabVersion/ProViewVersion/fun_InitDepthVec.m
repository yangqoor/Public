function [depth_vec, corres_points] = fun_InitDepthVec(FilePath, ...
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
    depth_vec = zeros(ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH, 1);

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
            xpro_int = round(xpro_mat(h,w) + 1);
            ypro_int = round(ypro_mat(h,w) + 1);
            if (xpro_int >= ProInfo.range_mat(1,1)) ...
                && (xpro_int <= ProInfo.range_mat(1,2)) ...
                && (ypro_int >= ProInfo.range_mat(2,1)) ...
                && (ypro_int <= ProInfo.range_mat(2,2))
                h_i = (ypro_int - ProInfo.range_mat(2,1)) + 1;
                w_i = (xpro_int - ProInfo.range_mat(1,1)) + 1;
                corres_points{h_i, w_i} = [h, w];
            end
        end
    end


    % Calculate depth mat
    for h = 1:ProInfo.RANGE_HEIGHT
        for w = 1:ProInfo.RANGE_WIDTH
            pvec_idx = (h-1)*ProInfo.RANGE_WIDTH + w;
            x_c = corres_points{h,w}(1,2);
            M = ParaSet.M(pvec_idx, :);
            D = ParaSet.D(pvec_idx, :);
            depth_vec(pvec_idx,1) = - (D(1)-D(3)*x_c) / (M(1)-M(3)*x_c);
        end
    end
end
