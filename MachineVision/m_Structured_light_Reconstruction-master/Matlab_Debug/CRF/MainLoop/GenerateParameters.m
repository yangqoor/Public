clear;

%% Inner Parameters
% cameraMatrix = [ 2400.0, 0.0, 640.0;
%     0.0, 2400.0, 512.0;
%     0.0, 0.0, 1.0];
% projectorMatrix = [ 2400.0, 0.0, 640.0;
%     0.0, 2400.0, 400.0;
%     0.0, 0.0, 1.0];
% rotationMatrix = [1.0, 0.0, 0.0;
%     0.0, 1.0, 0.0;
%     0.0, 0.0, 1.0];
% transportVector = [5.0;
%     0.0;
%     0.0];

cameraMatrix = [ 2321.35, 0.0, 639.50;
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
viewportMatrix = [200, 400;
    400, 600];

main_file_path = 'E:/Structured_Light_Data/20170613/1/';
% depth_file_path = 'depth_gd/';
% depth_file_name = 'depth';
pro_x_file_path = 'pro/';
pro_x_file_name = 'ipro_mat';
pro_y_file_path = 'pro/';
pro_y_file_name = 'jpro_mat';
cam_img_file_path = 'dyna/';
cam_img_file_name = '4RandDot';
file_suffix = '.txt';
cam_file_suffix = '.png';
data_frame_num = 30;
pattern = double(imread([main_file_path, '4RandDot0.png'])) / 255.0;

% For calculation
norm_sigma = 3;
                                                                  voxelSize = 0.1;
halfVoxelRange = 20;
save parameters.mat
