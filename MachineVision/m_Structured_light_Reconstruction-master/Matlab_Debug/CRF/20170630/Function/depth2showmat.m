function [ show_mat ] = depth2showmat( depth_mat, cameraMatrix, viewportMatrix )
    show_mat = zeros(size(depth_mat));
    
    gaussFilter = fspecial('gaussian', [7, 7], 1.6);
    depth_mat = imfilter(depth_mat, gaussFilter, 'replicate');
    
    x_mat = zeros(size(depth_mat));
    y_mat = zeros(size(depth_mat));
    for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
        for w = viewportMatrix(1, 1):viewportMatrix(1, 2)
            if depth_mat(h, w) > 0
                x_mat(h, w) = depth_mat(h, w) * (w - cameraMatrix(1, 3)) ...
                    / cameraMatrix(1, 1) * 10;
                y_mat(h, w) = depth_mat(h, w) * (h - cameraMatrix(2, 3)) ...
                    / cameraMatrix(2, 2) * 10;
            end
        end
    end

    camera_norm = [0; 0; 1];
    for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
        for w = viewportMatrix(1, 1):viewportMatrix(1, 2)
            if depth_mat(h, w) > 0
                vector1 = [x_mat(h+1, w+1); y_mat(h+1, w+1); depth_mat(h+1, w+1)] ...
                    - [x_mat(h-1, w-1); y_mat(h-1, w-1); depth_mat(h-1, w-1)];
                vector2 = [x_mat(h+1, w-1); y_mat(h+1, w-1); depth_mat(h+1, w-1)] ...
                    - [x_mat(h-1, w+1); y_mat(h-1, w+1); depth_mat(h-1, w+1)];
                point_norm = cross(vector1, vector2) * 1000;
%                 if point_norm(3) < 0
%                     disp(depth_mat(h-1:h+1, w-1:w+1));
%                 end
                show_mat(h, w) = dot(camera_norm, point_norm) / norm(point_norm);
            end
        end
    end

end
