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
    depth_vec = zeros(CamInfo.RANGE_HEIGHT*CamInfo.RANGE_WIDTH, 1);

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
    corres_points = cell(CamInfo.RANGE_HEIGHT, CamInfo.RANGE_WIDTH);
    for h_cam = 1:CamInfo.RANGE_HEIGHT
        for w_cam = 1:CamInfo.RANGE_WIDTH
            x_cam = w_cam + CamInfo.range_mat(1,1) - 1;
            y_cam = h_cam + CamInfo.range_mat(2,1) - 1;

            x_pro = xpro_mat(y_cam,x_cam) + 1;
            y_pro = ypro_mat(y_cam,x_cam) + 1;
            % h_pro = y_pro - ProInfo.range_mat(2,1) + 1;
            % w_pro = x_pro - ProInfo.range_mat(1,1) + 1;

            corres_points{h_cam, w_cam} = [y_pro,x_pro];
        end
    end


    % Calculate depth mat
    for h_cam = 1:CamInfo.RANGE_HEIGHT
        for w_cam = 1:CamInfo.RANGE_WIDTH
            cvec_idx = (h_cam-1)*CamInfo.RANGE_WIDTH + w_cam;
            x_pro = corres_points{h_cam,w_cam}(1,2);
            M = ParaSet.M(cvec_idx, :);
            D = ParaSet.D(cvec_idx, :);
            depth_vec(cvec_idx,1) = - (D(1)-D(3)*x_pro) / (M(1)-M(3)*x_pro);
        end
    end
end
