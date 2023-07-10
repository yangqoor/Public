%% Load part
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
for frame_idx = start_frame_num:data_frame_num
    camera_image{frame_idx, 1} = imread([main_file_path, cam_img_file_path, ...
        cam_img_file_name, num2str(frame_idx), cam_file_suffix]);
    camera_image{frame_idx, 1} = double(camera_image{frame_idx, 1}) / 255.0;
    % camera_image{frame_idx, 1} = NormalizeCameraImage(camera_image{frame_idx, 1}, viewportMatrix);
end

mask_mats = cell(data_frame_num, 1);
for i = 1:5
    load(['depth_mat/mask_mat', num2str(i+1), '.mat']);
    mask_mats{i, 1} = mask_mat;
end
total_belief_field = cell(5, 1);
for i = 1:4
    load(['belief_field/belief_field', num2str(i+1), '_iter_10.mat']);
    total_belief_field{i, 1} = beliefField;
end
load(['belief_field/belief_field6_iter_0.mat']);
total_belief_field{5, 1} = beliefField;

%% Some parameters
calculate_parameters.voxelSize = voxelSize;
calculate_parameters.hVoxelRange = halfVoxelRange;
calculate_parameters.hNborRange = halfNeighborRange;
calculate_parameters.norm_sigma_u = norm_sigma_u;
calculate_parameters.norm_sigma_p = norm_sigma_p;
calculate_parameters.norm_sigma_t = 2.0;
calculate_parameters.hMaskSRange = 5;
calculate_parameters.omega_u = 1.0;
calculate_parameters.omega_p = 1.0;
calculate_parameters.omega_t = 1.0;
calculate_parameters.k_nearest = 8;
epipolar_parameters.A = lineA;
epipolar_parameters.B = lineB;
epipolar_parameters.C = lineC;
fprintf('Load finished.\n');

%% Iteration
depth_mats_ori = FillOriDepthMap(total_belief_field, ...
        mask_mats, ...
        depth_mats{start_frame_num, 1}, ...
        calculate_parameters, ...
        viewportMatrix);
save depth_mats_ori.mat depth_mats_ori
% Check
tmp_delta_depth_mats = GetDeltaDepthsFromBeliefField(total_belief_field, ...
    mask_mats, ...
    calculate_parameters, ...
    viewportMatrix);
total_mask_mat = zeros(CAMERA_HEIGHT, CAMERA_WIDTH);
for i = 1:5
    total_mask_mat = total_mask_mat + mask_mats{i, 1};
end
total_mask_mat = (total_mask_mat > 0);
for i = 2:6
    depth_mats{i, 1} = depth_mats{i-1, 1} + tmp_delta_depth_mats{i-1, 1};
end
fprintf('Check finished.\n');
for iter_idx = 1:10
    total_belief_field = BeliefFieldIterationT(total_belief_field, ...
        camera_image, ...
        mask_mats, ...
        depth_mats_ori, ...
        pattern, ...
        epipolar_parameters, ...
        calculate_parameters, ...
        viewportMatrix);
    save(['total_belief_field', num2str(iter_idx), '.mat'], 'total_belief_field');
    depth_mats_ori = FillOriDepthMap(total_belief_field, ...
        mask_mats, ...
        depth_mats{start_frame_num, 1}, ...
        calculate_parameters, ...
        viewportMatrix);
    
    % Check
    tmp_delta_depth_mats = GetDeltaDepthsFromBeliefField(total_belief_field, ...
        mask_mats, ...
        calculate_parameters, ...
        viewportMatrix);
    total_mask_mat = zeros(CAMERA_HEIGHT, CAMERA_WIDTH);
    for i = 2:6
        total_mask_mat = total_mask_mat + mask_mats{i-1, 1};
    end
    total_mask_mat = (total_mask_mat > 0);
    for i = 2:6
        depth_mats{i, 1} = depth_mats{i-1, 1} + tmp_delta_depth_mats{i-1, 1};
    end
    fprintf('Check finished.\n');
end


%% Check
tmp_delta_depth_mats = GetDeltaDepthsFromBeliefField(total_belief_field, ...
    mask_mats, ...
    calculate_parameters, ...
    viewportMatrix);
total_mask_mat = zeros(CAMERA_HEIGHT, CAMERA_WIDTH);
for i = 2:6
    total_mask_mat = total_mask_mat + mask_mats{i-1, 1};
end
total_mask_mat = (total_mask_mat > 0);
for i = 2:6
    tmp_delta_depth_mats{i-1, 1} = Intersection(tmp_delta_depth_mats{i-1, 1}, mask_mats{i-1, 1}, viewportMatrix);
    depth_mats{i, 1} = depth_mats{i-1, 1} + tmp_delta_depth_mats{i-1, 1};
end
fprintf('Check finished.\n');

%% Debug
h_qry = 400;
w_qry = 700;
delta_vector = zeros(5, 1);
for i = 1:5
    delta_vector(i, 1) = tmp_delta_depth_mats{i, 1}(h_qry, w_qry);
end