% Input parameters
load parameters.mat
depth_file_path = 'depth_gd/';
depth_file_name = 'depth';
pro_x_file_path = 'pro_x_gd/';
pro_x_file_name = 'pro_x';
pro_y_file_path = 'pro_y_gd/';
pro_y_file_name = 'pro_y';
cam_img_file_path = 'camera_img/';
cam_img_file_name = 'camera_img';
file_suffix = '.txt';
cam_file_suffix = '.png';

pattern = double(imread([main_file_path, '4RandDot0.png'])) / 255.0;
mkdir([main_file_path, pro_x_file_path]);
mkdir([main_file_path, pro_y_file_path]);
mkdir([main_file_path, cam_img_file_path]);
for frame_idx = 1:data_frame_num
    % Load depth_mat, set pro_coordinates
    depth_mat = load([main_file_path, depth_file_path, ...
        depth_file_name, num2str(frame_idx), file_suffix]);
    pro_x_mat = zeros(CAMERA_HEIGHT, CAMERA_WIDTH);
    pro_y_mat = zeros(CAMERA_HEIGHT, CAMERA_WIDTH);
    camera_img = zeros(CAMERA_HEIGHT, CAMERA_WIDTH);

    % fill the mat
    for h = 1:CAMERA_HEIGHT
        for w = 1:CAMERA_WIDTH
            % camrea -> world
            point_camera = [w; h; 1];
            fx = cameraMatrix(1, 1); dx = cameraMatrix(1, 3);
            fy = cameraMatrix(2, 2); dy = cameraMatrix(2, 3);
            z = depth_mat(h, w);
            x = z * (w - dx) / fx;
            y = z * (h - dy) / fy;
            point_world = [x; y; z; 1];

            % world -> projector
            point_projector = projectorMatrix ...
                * [rotationMatrix, transportVector] * point_world;
            point_projector = point_projector / point_projector(3);

            % set pro_coord, camera color
            pro_x_mat(h, w) = point_projector(1);
            pro_y_mat(h, w) = point_projector(2);
            camera_img(h, w) = GetColorByCoordinate( ...
                pro_x_mat(h, w), pro_y_mat(h, w), ...
                PROJECTOR_WIDTH, PROJECTOR_HEIGHT, pattern);
            if (camera_img(h, w) > 1)
                disp(h, w, camera_img(h, w));
            end
        end
    end

    % Output
    file = fopen([main_file_path, pro_x_file_path, pro_x_file_name, ...
        num2str(frame_idx), file_suffix], 'w');
    for h = 1:CAMERA_HEIGHT
        for w = 1:CAMERA_WIDTH
            fprintf(file, '%.2f ', pro_x_mat(h, w));
        end
        fprintf(file, '\n');
    end
    fclose(file);
%     file = fopen([main_file_path, pro_y_file_path, pro_y_file_name, ...
%         num2str(frame_idx), file_suffix], 'w');
%     for h = 1:CAMERA_HEIGHT
%         for w = 1:CAMERA_WIDTH
%             fprintf(file, '%.2f ', pro_y_mat(h, w));
%         end
%         fprintf(file, '\n');
%                                                                                                                            
%     end
%     fclose(file);
    imwrite(camera_img, [main_file_path, cam_img_file_path, cam_img_file_name, ...
        num2str(frame_idx), cam_file_suffix]);
    
    fprintf('%d/%d finished.\n', frame_idx, data_frame_num);
end
