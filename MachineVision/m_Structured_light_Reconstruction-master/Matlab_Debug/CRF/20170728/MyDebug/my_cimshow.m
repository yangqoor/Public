function [] = my_cimshow(delta_depth_mat, mask_mat, viewportMatrix)

    [CAMERA_HEIGHT, CAMERA_WIDTH] = size(delta_depth_mat);
    show_color_mat = zeros(CAMERA_HEIGHT, CAMERA_WIDTH, 3);
    
    [mask_size_h, mask_size_w] = size(mask_mat);
    if mask_size_h == 0 && mask_size_w == 0
        mask_mat = ones(CAMERA_HEIGHT, CAMERA_WIDTH);
    end

    for h = viewportMatrix(2,1):viewportMatrix(2,2)
        for w = viewportMatrix(1,1):viewportMatrix(1,2)
            if mask_mat(h, w) == 0
                show_color_mat(h, w, :) = 0.5;
            else
                show_color_mat(h, w, :) = 1;
                if delta_depth_mat(h, w) > 0
                    show_color_mat(h, w, 3) = 1 - delta_depth_mat(h, w) * 2;
                elseif delta_depth_mat(h, w) < 0
                    show_color_mat(h, w, 1) = 1 + delta_depth_mat(h, w) * 10;
                end
            end
        end
    end

    imshow(show_color_mat(viewportMatrix(2,1):viewportMatrix(2,2), ...
        viewportMatrix(1,1):viewportMatrix(1,2), :));
end
