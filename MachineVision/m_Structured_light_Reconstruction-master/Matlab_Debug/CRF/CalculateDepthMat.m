%% Input parameters
load epipolar_line_parameters.mat
file_path = 'E:/Structured_Light_Data/20170519/1/';
cameraImage = imread([file_path, 'dyna/dyna_mat0.png']);
patternImage = imread([file_path, 'randDot0.bmp']);
[CAMERA_HEIGHT, CAMERA_WIDTH] = size(cameraImage);
[PATTERN_HEIGHT, PATTERN_WIDTH] = size(patternImage);
pro_x_gt = load([file_path, 'pro/ipro_mat0.txt']);
pro_y_gt = load([file_path, 'pro/jpro_mat0.txt']);

%% Depth mat
depthMatrix = zeros(CAMERA_HEIGHT, CAMERA_WIDTH);
for h = 1:CAMERA_HEIGHT
    for w = 1:CAMERA_WIDTH
        A = parameterA;
        B = parameterB;
        C = parameterC(h, w);
        D = parameterD(h, w);
        depthMatrix(h, w) = - (A - B * pro_x_gt(h, w)) ...
            / (C - D * pro_x_gt(h, w));
        if depthMatrix(h, w) < 0
            depthMatrix(h, w) = -1;
        end
        if depthMatrix(h, w) > 300
            depthMatrix(h, w) = -1;
        end
    end
end