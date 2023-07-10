function [ show_mat ] = de_ShowCamMat( cam_vec, CamInfo )
    cam_mat = reshape(cam_vec, CamInfo.RANGE_WIDTH, CamInfo.RANGE_HEIGHT)';
    show_mat = cam_mat;
%     imshow(cam_mat);
end

