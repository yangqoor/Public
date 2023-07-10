% Load parameters
load parameters.mat

% Load last frame information
last_camera_image = imread([main_file_path, cam_img_file_path, ...
    cam_img_file_name, '1', cam_file_suffix]);
last_camera_image = double(last_camera_image) / 255.0;
last_x_gt = load([main_file_path, pro_x_file_path, ...
    pro_x_file_name, '1', file_suffix]);
last_y_gt = load([main_file_path, pro_y_file_path, ...
    pro_y_file_name, '1', file_suffix]);
% last_depth_mat = load([main_file_path, depth_file_path, ...
%     depth_file_name, '1', file_suffix]);

for frame_idx = 2:data_frame_num
    % Load ground truth
    now_camera_image = imread([main_file_path, cam_img_file_path, ...
        cam_img_file_name, num2str(frame_idx), cam_file_suffix]);
    now_camera_image = double(now_camera_image) / 255.0;
    now_x_gt = load([main_file_path, pro_x_file_path, ...
        pro_x_file_name, num2str(frame_idx), file_suffix]);
    now_y_gt = load([main_file_path, pro_y_file_path, ...
        pro_y_file_name, num2str(frame_idx), file_suffix]);

    % Generate Q field and initialize it
    cameraImageNorm = NormalizeCameraImage(now_camera_image, viewportMatrix);
    beliefField = FillInitialBeliefField(cameraImageNorm, ...
        pattern, last_x_gt, last_y_gt, viewportMatrix, voxelSize, halfVoxelRange);
    fprintf('%d: initialized.\n', frame_idx);

    % Iteration
    for i_idx = 1:10
        beliefField = BeliefFieldIteration(beliefField, cameraImageNorm, ...
            pattern, last_depth_mat, viewportMatrix, voxelSize, halfVoxelRange);
        fprintf('%d_%d: iteration.\n', frame_idx, i_idx);
    end
end