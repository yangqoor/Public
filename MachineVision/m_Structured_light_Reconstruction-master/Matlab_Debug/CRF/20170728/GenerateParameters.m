clear;

%% Inner Parameters
camMat = [ 2321.35, 0.0, 639.50;
    0.0, 2326.22, 511.50;
    0.0, 0.0, 1.0];
projectorMatrix = [ 1986.02, 0.0, 598.16;
    0.0, 1983.35, 856.85;
    0.0, 0.0, 1.0];
rotationMatrix = [0.9945, 0.02305, -0.1020;
    -0.03917, 0.9865, -0.03917;
    0.09694, 0.1621, 0.9820];
transportVector = [10.31;
    -2.8678;
    7.8434];

CAMERA_HEIGHT = 1024;
CAMERA_WIDTH = 1280;
PROJECTOR_HEIGHT = 800;
PROJECTOR_WIDTH = 1280;
% viewportMatrix = [400, 600;
%     300, 500];
viewportMatrix = [600, 800;
    200, 400];

% main_file_path = '/home/rukun/Structured_Light_Data/20170724/Calibration_Square/';
% main_file_path = '/home/rukun/Structured_Light_Data/20170720/Sphere_2RandDot/';
main_file_path = 'E:/Structured_Light_Data/20170720/Statue_2RandDot/';
pro_x_file_path = 'pro/';
pro_x_file_name = 'ipro_mat';
pro_y_file_path = 'pro/';
pro_y_file_name = 'jpro_mat';
cam_img_file_path = 'dyna/';
cam_img_file_name = 'dyna_mat';
file_suffix = '.txt';
cam_file_suffix = '.png';
start_frame_num = 1;
data_frame_num = 20;
pattern = double(imread([main_file_path, '2RandDot0.png'])) / 255.0;

% For calculation
voxelSize = 0.04;
norm_sigma_u = voxelSize * 40;
norm_sigma_t = 1;
norm_sigma_p = 12;
halfVoxelRange = 20;
halfNeighborRange = 30;
omega_u = 1.0;
omega_s = 10.0;
omega_t = 1.0;

save parameters.mat
