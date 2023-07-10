%% Input arguments
file_path = 'E:/Structured_Light_Data/20170519/1/';
cameraMatrix = [ 2321.349, 0.0, 639.500;
    0.0, 2326.218, 511.5;
    0.0, 0.0, 1.0];
projectorMatrix = [1986.023, 0.0, 598.155;
    0.0, 1983.349, 856.845;
    0.0, 0.0, 1.0];
rotationMatrix = [0.99452, 0.023053, -0.10198;
    -0.039173, 0.98650, -0.15901;
    0.096938, 0.16214, 0.98200];
transportVector = [10.3084;
    -2.8678;
    7.8434];
camMat = [cameraMatrix, zeros(3, 1)];
proMat = projectorMatrix * [rotationMatrix, transportVector];

cameraImage = imread([file_path, 'dyna/dyna_mat0.png']);
patternImage = imread([file_path, 'randDot0.bmp']);
[CAMERA_HEIGHT, CAMERA_WIDTH] = size(cameraImage);
[PATTERN_HEIGHT, PATTERN_WIDTH] = size(patternImage);

%% parameters for depth
parameterA = camMat(1, 1) * camMat(2, 2) * proMat(1, 4);
parameterB = camMat(1, 1) * camMat(2, 2) * proMat(3, 4);
parameterC = zeros(CAMERA_HEIGHT, CAMERA_WIDTH);
parameterD = zeros(CAMERA_HEIGHT, CAMERA_WIDTH);
for h = 1:CAMERA_HEIGHT
    for w = 1:CAMERA_WIDTH
        parameterC(h, w) = (w - camMat(1, 3)) * camMat(2, 2) * proMat(1, 1) ...
            + (h - camMat(2, 3)) * camMat(1, 1) * proMat(1, 2) ...
            + camMat(1, 1) * camMat(2, 2) * proMat(1, 3);
        parameterD(h, w) = (w - camMat(1, 3)) * camMat(2, 2) * proMat(3, 1) ...
            + (h - camMat(2, 3)) * camMat(1, 1) * proMat(3, 2) ...
            + camMat(1, 1) * camMat(2, 2) * proMat(3, 3);
    end
end

%% epipolar line
lineA = zeros(CAMERA_HEIGHT, CAMERA_WIDTH);
lineB = zeros(CAMERA_HEIGHT, CAMERA_WIDTH);
lineC = zeros(CAMERA_HEIGHT, CAMERA_WIDTH);
pointOrigin = getWorld2Projector([0; 0; 0; 1]);
for h = 1:CAMERA_HEIGHT
    for w = 1:CAMERA_WIDTH
        f_x = camMat(1, 1); f_y = camMat(2, 2);
        d_x = camMat(1, 3); d_y = camMat(2, 3);
        assume_z = 30;
        assume_x = assume_z * (w - d_x) / f_x;
        assume_y = assume_z * (w - d_y) / f_y;
        pointAssume = getWorld2Projector([assume_x; assume_y; assume_z; 1]);
        x1 = pointOrigin(1);
        y1 = pointOrigin(2);
        x2 = pointAssume(1);
        y2 = pointAssume(2);
        lineA(h, w) = y2 - y1;
        lineB(h, w) = x1 - x2;
        lineC(h, w) = x2 * y1 - x1 * y2;
    end
end

save('stereo_parameters.mat', 'parameterA', 'parameterB', 'parameterC', 'parameterD');
save('epipolar_line_parameters.mat', 'lineA', 'lineB', 'lineC'); 
