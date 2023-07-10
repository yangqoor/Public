load epipolar_line_parameters.mat
lineC = ones(size(lineA));

main_file_path = 'E:/Structured_Light_Data/20170613/1/';
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

for image_idx = 1:30
    cameraImage = imread([main_file_path, ...
        cam_img_file_path, ...
        cam_img_file_name, ...
        num2str(image_idx), ...
        cam_file_suffix]);
    xpro_mat = load([main_file_path, ...
        pro_x_file_path, ...
        pro_x_file_name, ...
        num2str(image_idx), ...
        file_suffix]);
    show_mat = WritePatternColor(cameraImage, pattern, xpro_mat, lineA, lineB);
    imshow(show_mat);
    imwrite(show_mat, ['./PatternColorResult/show', num2str(image_idx), '.png']);
end
