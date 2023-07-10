function [x_pro_mat, y_pro_mat, depth_mat] = fun_InitDepthVec(FilePath, ...
    CamInfo, ...
    ParaSet)
% Calculate first depth mat

    % Read xpro_mat, ypro_mat
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

    % Intersect xpro_mat, ypro_mat
    for x_cam = CamInfo.range_mat(1,1):CamInfo.range_mat(1,2)
        for y_cam = CamInfo.range_mat(2,1):CamInfo.range_mat(2,2)
            if xpro_mat(y_cam,x_cam) < 0
                xpro_mat(y_cam,x_cam) ...
                    = (xpro_mat(y_cam,x_cam-1)+xpro_mat(y_cam,x_cam+1)) / 2;
            end
            if ypro_mat(y_cam,x_cam) < 0
                ypro_mat(y_cam,x_cam) ...
                    = (ypro_mat(y_cam-1,x_cam)+ypro_mat(y_cam+1,x_cam)) / 2;
            end
        end
    end

    % Set x_pro, y_pro
    x_pro_mat = xpro_mat(CamInfo.range_mat(2,1):CamInfo.range_mat(2,2), ...
        CamInfo.range_mat(1,1):CamInfo.range_mat(1,2));
    y_pro_mat = ypro_mat(CamInfo.range_mat(2,1):CamInfo.range_mat(2,2), ...
        CamInfo.range_mat(1,1):CamInfo.range_mat(1,2));

    % Calculate depth_fine mat
    depth_mat = zeros(CamInfo.R_HEIGHT, CamInfo.R_WIDTH);
    for h_cam = 1:CamInfo.R_HEIGHT
        for w_cam = 1:CamInfo.R_WIDTH
            cvec_idx = (h_cam-1)*CamInfo.R_WIDTH + w_cam;
            x_pro = x_pro_mat(h_cam,w_cam);
            M = ParaSet.M(cvec_idx, :);
            D = ParaSet.D(cvec_idx, :);

            depth_mat(h_cam,w_cam) = -(D(1)-D(3)*x_pro) / (M(1)-M(3)*x_pro);
        end
    end

end
