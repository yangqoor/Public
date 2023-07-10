% Set parameters
warning('off');
clear;
load ParaEpi.mat

% Create lineA, lineB, lineC
EpiLine.A = zeros(CamInfo.RANGE_HEIGHT, CamInfo.RANGE_WIDTH);
EpiLine.B = zeros(CamInfo.RANGE_HEIGHT, CamInfo.RANGE_WIDTH);
EpiLine.C = ones(CamInfo.RANGE_HEIGHT, CamInfo.RANGE_WIDTH);
xdis_threhold = 10;

% Fill valid points for camera pixels
valid_points = cell(CamInfo.RANGE_HEIGHT, CamInfo.RANGE_WIDTH);
valid_mask = zeros(CamInfo.RANGE_HEIGHT, CamInfo.RANGE_WIDTH);
for frm_idx = 0:total_frame_num-1
    fprintf(['F', num2str(frm_idx), ':']);

    if frm_idx >= 3 && frm_idx <= 5
        continue;
    end
    
    
    % load
    xpro_mat = load([FilePath.main_file_path, ...
        FilePath.xpro_file_path, ...
        FilePath.xpro_file_name, ...
        num2str(frm_idx), ...
        FilePath.pro_file_suffix]);
    ypro_mat = load([FilePath.main_file_path, ...
        FilePath.ypro_file_path, ...
        FilePath.ypro_file_name, ...
        num2str(frm_idx), ...
        FilePath.pro_file_suffix]);
    imshow(xpro_mat(CamInfo.range_mat(2,1):CamInfo.range_mat(2,2), CamInfo.range_mat(1,1):CamInfo.range_mat(1,2)),[]);

    % Intersect
%     for h = CamInfo.inter_range(2,1):CamInfo.inter_range(2,2)
%         for w = CamInfo.inter_range(1,1):CamInfo.inter_range(1,2)
%             if xpro_mat(h,w) < 0
%                 xpro_mat(h,w) = (xpro_mat(h,w-1) + xpro_mat(h,w+1)) / 2;
%             end
%             if ypro_mat(h,w) < 0
%                 ypro_mat(h,w) = (ypro_mat(h-1,w) + ypro_mat(h+1,w)) / 2;
%             end
%         end
%     end

    % Fill valid_points
    for h = CamInfo.range_mat(2,1):CamInfo.range_mat(2,2)
        for w = CamInfo.range_mat(1,1):CamInfo.range_mat(1,2)
            x_pro = xpro_mat(h,w) + 1;
            y_pro = ypro_mat(h,w) + 1;
            h_cam = h - CamInfo.range_mat(2,1) + 1;
            w_cam = w - CamInfo.range_mat(1,1) + 1;
            if x_pro > 0 && y_pro > 0
                valid_points{h_cam,w_cam} = [valid_points{h_cam,w_cam}; ...
                    [x_pro, y_pro]];
            end
        end
    end
end

% Calculate
fprintf('Calculation');
for h_cam = 1:CamInfo.RANGE_HEIGHT
    for w_cam = 1:CamInfo.RANGE_WIDTH
        if size(valid_points{h_cam,w_cam},1) == 0
            continue;
        end
        max_val = max(valid_points{h_cam,w_cam}(:,1));
        min_val = min(valid_points{h_cam,w_cam}(:,1));
        if max_val - min_val > xdis_threhold
            vecX = valid_points{h_cam,w_cam} \ ones(size(valid_points{h_cam,w_cam},1),1);
            valid_mask(h_cam,w_cam) = 1;
            EpiLine.A(h_cam,w_cam) = vecX(1);
            EpiLine.B(h_cam,w_cam) = vecX(2);
        end
    end
end
fprintf('\n');

save('EpipolarPara.mat', 'EpiLine');
