%% Input parameters
load parameters.mat
file_path = [main_file_path, 'depth_gd/'];
file_name = 'depth';
file_suffix = '.txt';
frame_num = 20;

%% Output depth mat
depth_mat = zeros(CAMERA_HEIGHT, CAMERA_WIDTH, frame_num);
start_depth = 20.0;
delta_depth = 0.2;
for frame_idx = 1:frame_num
    depth_mat(:, :, frame_idx) = start_depth + delta_depth * frame_idx;
end

%% Write into files
mkdir(file_path);
for frame_idx = 1:frame_num
    file = fopen([file_path, file_name, num2str(frame_idx), file_suffix], 'w');
    for h = 1:CAMERA_HEIGHT
        for w = 1:CAMERA_WIDTH
            fprintf(file, '%.2f ', depth_mat(h, w, frame_idx));
        end
        fprintf(file, '\n');
    end
    fclose(file);
    fprintf('%d frame finished.\n', frame_idx);
end
