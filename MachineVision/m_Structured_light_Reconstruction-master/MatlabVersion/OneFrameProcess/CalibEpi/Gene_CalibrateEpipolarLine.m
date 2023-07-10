% Set parameters
warning('off');
clear;
load GeneralParaEpi.mat

% Create lineA, lineB, lineC
EpiLine.lineA = zeros(CamInfo.R_HEIGHT, CamInfo.R_WIDTH);
EpiLine.lineB = zeros(size(EpiLine.lineA));
EpiLine.lineC = ones(size(EpiLine.lineA));
xdis_threhold = 10;
xnum_threhold = 5;

% Fill valid points
valid_points = cell(CamInfo.R_HEIGHT, CamInfo.R_WIDTH);

for frame_idx = 0:total_frame_num-1
    fprintf(['F', num2str(frame_idx), ': ']);

    % Load and Intersect
    xpro_mat = load([FilePath.main_file_path, ...
        FilePath.xpro_file_path, ...
        FilePath.xpro_file_name, ...
        num2str(frame_idx), ...
        FilePath.pro_file_suffix]);
    ypro_mat = load([FilePath.main_file_path, ...
        FilePath.ypro_file_path, ...
        FilePath.ypro_file_name, ...
        num2str(frame_idx), ...
        FilePath.pro_file_suffix]);
    img_mat = imread([FilePath.main_file_path, ...
        FilePath.img_file_path, ...
        FilePath.img_file_name, ...
        num2str(frame_idx), ...
        FilePath.img_file_suffix]);
    fprintf('L;');

    % Find Correspondence and refinement

    for h_cam = 1:CamInfo.R_HEIGHT
        for w_cam = 1:CamInfo.R_WIDTH
            x_cam = w_cam + CamInfo.range_mat(1,1) - 1;
            y_cam = h_cam + CamInfo.range_mat(2,1) - 1;
            x_pro = xpro_mat(y_cam,x_cam);
            y_pro = ypro_mat(y_cam,x_cam);
            if (x_pro>0) && (y_pro>0)
                valid_points{h_cam,w_cam} = [valid_points{h_cam,w_cam}; ...
                    x_pro, y_pro];
            end

        end
    end

    show_mat = xpro_mat(CamInfo.range_mat(2,1):CamInfo.range_mat(2,2), ...
        CamInfo.range_mat(1,1):CamInfo.range_mat(1,2));
    imshow(show_mat);

    fprintf('.\n')
end
fprintf('Calculation...\n');

% Fill valid mat according to valid_points
valid_mat = zeros(CamInfo.R_HEIGHT, CamInfo.R_WIDTH);
for h_cam = 1:CamInfo.R_HEIGHT
    for w_cam = 1:CamInfo.R_WIDTH
        if size(valid_points{h_cam,w_cam},1) < xnum_threhold
            continue;
        end
        xmax_val = max(valid_points{h_cam,w_cam}(:,1));
        xmin_val = min(valid_points{h_cam,w_cam}(:,1));
        if xmax_val - xmin_val > xdis_threhold
            vecY = ones(size(valid_points{h_cam,w_cam},1),1);
            vecX = valid_points{h_cam,w_cam} \ vecY;
            valid_mat(h_cam,w_cam) = 1;
            EpiLine.lineA(h_cam,w_cam) = vecX(1);
            EpiLine.lineB(h_cam,w_cam) = vecX(2);
        end
    end
end
imshow(valid_mat);

save('ParaEpi.mat', 'EpiLine');
