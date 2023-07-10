%% Input parameters
load epipolar_line_parameters.mat
file_path = 'E:/Structured_Light_Data/20170519/1/';
cameraImage = imread([file_path, 'dyna/dyna_mat0.png']);
patternImage = imread([file_path, 'randDot0.bmp']);
[CAMERA_HEIGHT, CAMERA_WIDTH] = size(cameraImage);
[PATTERN_HEIGHT, PATTERN_WIDTH] = size(patternImage);
pro_x_gt = load([file_path, 'pro/ipro_mat0.txt']);
pro_y_gt = load([file_path, 'pro/jpro_mat0.txt']);

%% Calculate y_p in projector
pro_y_calculate = zeros(CAMERA_HEIGHT, CAMERA_WIDTH);
line_error = zeros(CAMERA_HEIGHT, CAMERA_WIDTH);
for h = 1:CAMERA_HEIGHT
    for w = 1:CAMERA_WIDTH
        if (pro_y_gt(h, w) < 0) || (pro_x_gt(h, w) < 0)
            pro_y_calculate(h, w) = pro_y_gt(h, w);
        else
            pro_y_calculate(h, w) = - (lineA(h, w) / lineB(h, w)) * pro_x_gt(h, w) - (lineC(h, w) / lineB(h, w));
            line_error(h, w) = lineA(h, w) * pro_x_gt(h, w) + lineB(h, w) * pro_y_gt(h, w) + lineC(h, w);
        end
    end
end

error = pro_y_calculate - pro_y_gt;