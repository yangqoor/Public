% Load parameters
load parameters.mat
load epipolar_line_parameters.mat

% Load last frame information
last_camera_image = imread([main_file_path, cam_img_file_path, ...
    cam_img_file_name, '1', cam_file_suffix]);
last_camera_image = double(last_camera_image) / 255.0;
last_x_gt = load([main_file_path, pro_x_file_path, ...
    pro_x_file_name, '1', file_suffix]);
last_y_gt = load([main_file_path, pro_y_file_path, ...
    pro_y_file_name, '1', file_suffix]);

last_depth_mat = zeros(size(last_camera_image));
valid_mask = ones(size(last_camera_image));
for h = 1:CAMERA_HEIGHT
    for w = 1:CAMERA_WIDTH
        x_p = last_x_gt(h, w);
        y_p = last_y_gt(h, w);
        if (x_p > 0) && (y_p > 0)
            last_depth_mat(h, w) = xpro2depth(w, h, x_p);
        else
            valid_mask(h, w) = 0;
        end
    end
end
for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
    for w = viewportMatrix(1, 1):viewportMatrix(1, 2)
        if valid_mask(h, w) == 0
            last_x_gt(h, w) = (last_x_gt(h-1, w) + last_x_gt(h+1, w)) / 2;
            last_depth_mat(h, w) = last_depth_mat(h, w - 1);
        end
    end
end

% last_depth_mat = load([main_file_path, depth_file_path, ...
%     depth_file_name, '1', file_suffix]);

for frame_idx = 2:2
    % Load now frame information
    now_camera_image = imread([main_file_path, cam_img_file_path, ...
        cam_img_file_name, num2str(frame_idx), cam_file_suffix]);
    now_camera_image = double(now_camera_image) / 255.0;
    now_x_gt = load([main_file_path, pro_x_file_path, ...
        pro_x_file_name, num2str(frame_idx), file_suffix]);
    now_y_gt = load([main_file_path, pro_y_file_path, ...
        pro_y_file_name, num2str(frame_idx), file_suffix]);

    now_depth_mat = zeros(size(now_camera_image));
    now_valid_mask = ones(size(now_camera_image));
    for h = 1:CAMERA_HEIGHT
        for w = 1:CAMERA_WIDTH
            x_p = now_x_gt(h, w);
            y_p = now_y_gt(h, w);
            if (x_p > 0) && (y_p > 0)
                now_depth_mat(h, w) = xpro2depth(w, h, x_p);
            else
                now_valid_mask(h, w) = 0;
            end
        end
    end
    for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
        for w = viewportMatrix(1, 1):viewportMatrix(1, 2)
            if now_valid_mask(h, w) == 0
                now_depth_mat(h, w) = now_depth_mat(h, w - 1);
            end
        end
    end
    
    % Generate Q field and initialize it
    % cameraImageNorm = NormalizeCameraImage(now_camera_image, viewportMatrix);
    beliefField = FillInitialBeliefField(now_camera_image, ...
        pattern, ...
        last_depth_mat, ...
        now_depth_mat, ...
        lineA, ...
        lineB, ...
        lineC, ...
        viewportMatrix, ...
        voxelSize, ...
        halfVoxelRange);
    fprintf('%d: initialized.\n', frame_idx);
    % Iteration
    
    for i_idx = 1:5
        beliefField = BeliefFieldIteration(beliefField, ...
            pattern, ...
            last_depth_mat, ...
            now_depth_mat, ...
            lineA, ...
            lineB, ...
            lineC, ...
            viewportMatrix, ...
            voxelSize, ...
            halfVoxelRange);
        save(['beliefField', num2str(i_idx), '.mat'], 'beliefField');
        fprintf('%d_%d: iteration.\n', frame_idx, i_idx);
    end
end
