load parameters.mat
load epipolar_line_parameters.mat

%% Load All Information
camera_image = cell(data_frame_num, 1);
% xpro_mats = cell(5, 1);
% ypro_mats = cell(5, 1);
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

for frame_idx = start_frame_num:data_frame_num
    camera_image{frame_idx, 1} = imread([main_file_path, cam_img_file_path, ...
        cam_img_file_name, num2str(frame_idx), cam_file_suffix]);
    camera_image{frame_idx, 1} = double(camera_image{frame_idx, 1}) / 255.0;
    % camera_image{frame_idx, 1} = NormalizeCameraImage(camera_image{frame_idx, 1}, viewportMatrix);
end
