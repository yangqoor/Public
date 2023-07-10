function [ mask_mat ] = SetMaskMat( last_camera_image, now_camera_image, viewportMatrix )
    mask_mat = zeros(size(last_camera_image));
    threhold = 0.2;
    
    mask_mat1 = zeros(size(last_camera_image));
    for h = viewportMatrix(2,1):viewportMatrix(2,2)
        for w = viewportMatrix(1,1):viewportMatrix(1,2)
            if abs(now_camera_image(h, w) - 0.5) > threhold
                mask_mat1(h, w) = 1;
            end
        end
    end

    mask_mat2 = zeros(size(last_camera_image));
    for h = viewportMatrix(2,1):viewportMatrix(2,2)
        for w = viewportMatrix(1,1):viewportMatrix(1,2)
            if abs(now_camera_image(h, w) - last_camera_image(h, w)) > threhold*2
                mask_mat2(h, w) = 1;
            end
        end
    end
    
    mask_mat3 = zeros(size(last_camera_image));
    for h = viewportMatrix(2,1):viewportMatrix(2,2)
        for w = viewportMatrix(1,1):viewportMatrix(1,2)
            if now_camera_image(h, w) < 0.4 && last_camera_image(h, w) > 0.6
                mask_mat3(h, w) = 1;
            elseif now_camera_image(h, w) > 0.6 && last_camera_image(h, w) < 0.4
                mask_mat3(h, w) = 1;
            end
        end
    end
    
    mask_mat = mask_mat3;
end

