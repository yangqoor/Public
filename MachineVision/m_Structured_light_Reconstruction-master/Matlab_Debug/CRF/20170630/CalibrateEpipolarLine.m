% load parameters.mat
warning('off');
% 
lineA = zeros(CAMERA_HEIGHT, CAMERA_WIDTH);
lineB = zeros(CAMERA_HEIGHT, CAMERA_WIDTH);
lineC = ones(CAMERA_HEIGHT, CAMERA_WIDTH);
threhold = 10;

valid_points = cell(CAMERA_HEIGHT, CAMERA_WIDTH);

for frame_idx = 0:29
    xpro_mat = load([main_file_path, pro_x_file_path, ...
        pro_x_file_name, num2str(frame_idx), file_suffix]);
    ypro_mat = load([main_file_path, pro_y_file_path, ...
        pro_y_file_name, num2str(frame_idx), file_suffix]);
    for h = 1:CAMERA_HEIGHT
        for w = 1:CAMERA_WIDTH
            if (xpro_mat(h, w) > 0) && (ypro_mat(h, w) > 0)
                valid_points{h, w} = [valid_points{h, w}; ...
                    [xpro_mat(h, w), ypro_mat(h, w)]];
            end
        end
    end
    fprintf('.');
end
fprintf('\n');
valid_mat = zeros(CAMERA_HEIGHT, CAMERA_WIDTH);

for h = 1:CAMERA_HEIGHT
    for w = 1:CAMERA_WIDTH
        if size(valid_points{h, w}, 1) == 0
            continue;
        end
        max_val = max(valid_points{h, w}(:, 1));
        min_val = min(valid_points{h, w}(:, 1));
        if max_val - min_val > threhold
            X = valid_points{h, w} \ ones(size(valid_points{h, w}, 1), 1);
            valid_mat(h, w) = 1;
            lineA(h, w) = X(1);
            lineB(h, w) = X(2);
        end
    end
end

save('epipolar_line_parameters.mat', 'lineA', 'lineB', 'lineC');
