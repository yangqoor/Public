clear;

%% Inner Parameters
cameraMatrix = [ 2400.0, 0.0, 640.0;
    0.0, 2400.0, 512.0;
    0.0, 0.0, 1.0];
projectorMatrix = [ 2400.0, 0.0, 640.0;
    0.0, 2400.0, 400.0;
    0.0, 0.0, 1.0];
rotationMatrix = [1.0, 0.0, 0.0;
    0.0, 1.0, 0.0;
    0.0, 0.0, 1.0];
transportVector = [5.0;
    0.0;
    0.0];

CAMERA_HEIGHT = 1024;
CAMERA_WIDTH = 1280;
PROJECTOR_HEIGHT = 800;
PROJECTOR_WIDTH = 1280;
main_file_path = 'E:/Structured_Light_Data/20170610/1/';
data_frame_num = 20;

save parameters.mat
