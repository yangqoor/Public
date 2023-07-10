%% Set parameters
main_file_path = '/home/rukun/Structured_Light_Data/20170630/2/';
% main_file_path = 'E:/Structured_Light_Data/20170630/2/';
pro_x_file_path = 'pro/';
pro_x_file_name = 'ipro_mat';
pro_y_file_path = 'pro/';
pro_y_file_name = 'jpro_mat';
cam_img_file_path = 'dyna/';
cam_img_file_name = '4RandDot';
file_suffix = '.txt';
cam_file_suffix = '.png';
data_frame_num = 29;
pattern = double(imread([main_file_path, '4RandDot0.png'])) / 255.0;

CAMERA_HEIGHT = 1024;
CAMERA_WIDTH = 1280;
PROJECTOR_HEIGHT = 800;
PROJECTOR_WIDTH = 1280;
viewportMatrix = [300, 500;
    600, 800];

%% Load Depth Mats
camera_image = cell(data_frame_num, 1);
xpro_mats = cell(data_frame_num, 1);
ypro_mats = cell(data_frame_num, 1);
depth_mats = cell(data_frame_num, 1);
valid_mats = cell(data_frame_num, 1);
fprintf('Loading');
for idx = 1:data_frame_num
    camera_image{idx, 1} = imread([main_file_path, cam_img_file_path, ...
        cam_img_file_name, num2str(idx), cam_file_suffix]);
    camera_image{idx, 1} = double(camera_image{idx, 1}) / 255.0;
    xpro_mats{idx, 1} = load([main_file_path, pro_x_file_path, ...
        pro_x_file_name, num2str(idx), file_suffix]);
    ypro_mats{idx, 1} = load([main_file_path, pro_y_file_path, ...
        pro_y_file_name, num2str(idx), file_suffix]);

    xpro_mats{idx, 1} = HoleFilling(xpro_mats{idx, 1}, 2, viewportMatrix);
    ypro_mats{idx, 1} = HoleFilling(ypro_mats{idx, 1}, 2, viewportMatrix);
    [depth_mats{idx, 1}, valid_mats{idx, 1}] = FillDepthMat(xpro_mats{idx, 1}, ...
        ypro_mats{idx, 1}, ...
        viewportMatrix);
    fprintf('.');
end
fprintf('\n');

%% Calculate Delta_depth
delta_depth_mats = cell(data_frame_num, 1);
for idx = 2:data_frame_num
    delta_depth_mats{idx, 1} = zeros(CAMERA_HEIGHT, CAMERA_WIDTH);
    for h = viewportMatrix(2, 1):viewportMatrix(2, 2)
        for w = viewportMatrix(1, 1):viewportMatrix(1, 2)
            delta_depth_mats{idx, 1}(h, w) = depth_mats{idx, 1}(h, w) - depth_mats{idx-1, 1}(h, w);
        end
    end
end

save delta_depth_mats.mat delta_depth_mats
save depth_mats.mat depth_mats
