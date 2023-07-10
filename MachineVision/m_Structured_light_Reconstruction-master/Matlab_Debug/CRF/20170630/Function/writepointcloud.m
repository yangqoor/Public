function [  ] = writepointcloud( depth_mats, ...
    camera_mat, ...
    file_path, ...
    file_name, ...
    file_suffix, ...
    viewportMatrix )
%WRITEPOINTCLOUD 此处显示有关此函数的摘要
%   此处显示详细说明

    for t = 1:4
        total_file_name = [file_path, file_name, '_t', num2str(t), file_suffix];
        x_mat = zeros(size(depth_mats));
        y_mat = zeros(size(depth_mats));
        fid = fopen(total_file_name, 'w');
        for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
            for w = viewportMatrix(1, 1):viewportMatrix(1, 2)
                if depth_mats{t}(h, w) > 0 && depth_mats{t}(h, w) < 40.0
                    x_mat(h, w) = depth_mats{t}(h, w) * (w - camera_mat(1, 3)) ...
                        / camera_mat(1, 1);
                    y_mat(h, w) = depth_mats{t}(h, w) * (h - camera_mat(2, 3)) ...
                        / camera_mat(2, 2);
                    fprintf(fid, '%.2f %.2f %.2f \n', x_mat(h, w), y_mat(h, w), depth_mats{t}(h, w));
                end
            end
        end
        fclose(fid);
    end
end

