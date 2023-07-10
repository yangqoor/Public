load ParaEpi.mat
load GeneralPara.mat

% New parameters
cam_mats = cell(total_frame_num, 1);
x_pro_mats = cell(total_frame_num, 1);
y_pro_mats = cell(total_frame_num, 1);
depth_mats = cell(total_frame_num, 1);
match_res = cell(total_frame_num, 1);
pro_rad = 4;
% h_scale_mats = cell(total_frame_num, 1);
% w_scale_mats = cell(total_frame_num, 1);
pattern_max_val = zeros(ProInfo.HEIGHT, ProInfo.WIDTH);
pattern_min_val = zeros(ProInfo.HEIGHT, ProInfo.WIDTH);
for x_pro = ProInfo.range_mat(1,1)-20:ProInfo.range_mat(1,2)+20
    for y_pro = ProInfo.range_mat(2,1)-20:ProInfo.range_mat(2,2)+20
        part_pattern = pattern(y_pro-pro_rad:y_pro+pro_rad, ...
            x_pro-pro_rad:x_pro+pro_rad);
        pattern_max_val(y_pro,x_pro) = max(max(double(part_pattern)));
        pattern_min_val(y_pro,x_pro) = min(min(double(part_pattern)));
    end
end

% Set initial frame info
fprintf('Initial...');
cam_mats = fun_ReadCamVecFromFile(FilePath, ...
    CamInfo, ...
    total_frame_num);
[x_pro_mats{1,1}, y_pro_mats{1,1}, depth_mats{1,1}] = fun_InitDepthVec(FilePath, ...
    CamInfo, ...
    ParaSet);
fprintf('finished.\n');
