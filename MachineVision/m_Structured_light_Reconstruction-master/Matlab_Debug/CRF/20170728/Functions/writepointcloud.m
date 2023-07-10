function [  ] = writepointcloud( depth, cameraMatrix, file_name, viewportMatrix, mask_mat )
%WRITEPOINTCLOUD 此处显示有关此函数的摘要
%   此处显示详细说明
    point_cloud = [];
    x_mat = zeros(size(depth));
    y_mat = zeros(size(depth));
    fid = fopen(file_name, 'w');
    for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
        for w = viewportMatrix(1, 1):viewportMatrix(1, 2)
            if depth(h, w) > 0 && depth(h, w) < 40.0
                x_mat(h, w) = depth(h, w) * (w - cameraMatrix(1, 3)) ...
                    / cameraMatrix(1, 1);
                y_mat(h, w) = depth(h, w) * (h - cameraMatrix(2, 3)) ...
                    / cameraMatrix(2, 2);
                fprintf(fid, '%.2f %.2f %.2f \n', x_mat(h, w), y_mat(h, w), depth(h, w));
            end
        end
    end
    fclose(fid);
end

