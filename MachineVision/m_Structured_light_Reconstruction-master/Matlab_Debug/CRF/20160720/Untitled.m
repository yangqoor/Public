load parameters.mat
load epipolar_line_parameters.mat
camera_image = cell(data_frame_num, 1);
depth_mats = cell(data_frame_num, 1);
valid_mats = cell(data_frame_num, 1);

xpro_mat = load([main_file_path, pro_x_file_path, ...
    pro_x_file_name, '0', file_suffix]);
ypro_mat = load([main_file_path, pro_y_file_path, ...
    pro_y_file_name, '0', file_suffix]);
xpro_mat = HoleFilling(xpro_mat, 2, viewportMatrix);
ypro_mat = HoleFilling(ypro_mat, 2, viewportMatrix);
[depth_mats{start_frame_num, 1}, ~] = FillDepthMat(xpro_mat, ...
    ypro_mat, ...
    viewportMatrix);

frame_idx = start_frame_num;
camera_image{frame_idx, 1} = imread([main_file_path, cam_img_file_path, ...
    cam_img_file_name, num2str(frame_idx), cam_file_suffix]);
camera_image{frame_idx, 1} = double(camera_image{frame_idx, 1}) / 255.0;
% camera_image{frame_idx, 1} = NormalizeCameraImage(camera_image{frame_idx, 1}, viewportMatrix);


%% Calculation
match_mat = ones(CAMERA_HEIGHT, CAMERA_WIDTH);
sum_right = 0;
for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
    for w = viewportMatrix(1, 1):viewportMatrix(1, 2)
        xpro = xpro_mat(h, w);
%        ypro = ypro_mat(h, w);
        ypro = xpro2ypro(w, h, xpro, lineA, lineB, lineC);
        p_xy = GetColorByXYpro(xpro, ypro, pattern);
        c_xy = camera_image{frame_idx, 1}(h, w);
        match_mat(h, w) = color_alpha(c_xy, p_xy);
%         if abs(c_xy - 0.5) < 0.2
%             match_mat(h, w) = 0.5;
%         end
        if match_mat(h, w) > 10
            match_mat(h, w) = 0;
        else
            sum_right = sum_right + 1;
        end
    end
end
figure, my_imshow(match_mat, viewportMatrix, true);