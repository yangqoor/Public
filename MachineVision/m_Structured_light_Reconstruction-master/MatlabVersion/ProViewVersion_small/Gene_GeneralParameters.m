clear;

% Cam Pro Inner parameters
CalibMat.cam = [ 2797.80, 0.0, 639.50;
    0.0, 2790.08, 511.50;
    0.0, 0.0, 1.0];
CalibMat.pro = [ 1587.39, 0.0, 473.22;
    0.0, 1595.35, 604.52;
    0.0, 0.0, 1.0];
CalibMat.rot = [0.9992, 0.007423, -0.03896;
    -0.01081, 0.9961, -0.08734;
    0.03816, 0.08769, 0.9954];
CalibMat.trans = [9.4647;
    0.06125;
    -14.724];
CalibMat.proMat = [CalibMat.pro, zeros(3,1)];
CalibMat.camMat = CalibMat.cam * [inv(CalibMat.rot), -CalibMat.trans];

% CamInfo set
CamInfo.HEIGHT = 1024;
CamInfo.WIDTH = 1280;
% CamInfo.range_mat = [287+60, 631+60; 408-10, 727-10];
CamInfo.range_mat = [434, 865-50; 463, 809];
% CamInfo.range_mat = [287, 631; 408, 727];
CamInfo.RANGE_HEIGHT = CamInfo.range_mat(2,2) - CamInfo.range_mat(2,1) + 1;
CamInfo.RANGE_WIDTH = CamInfo.range_mat(1,2) - CamInfo.range_mat(1,1) + 1;
CamInfo.coord_trans = zeros(CamInfo.RANGE_HEIGHT*CamInfo.RANGE_WIDTH, 2);
for h = 1:CamInfo.RANGE_HEIGHT
    for w = 1:CamInfo.RANGE_WIDTH
        CamInfo.coord_trans((h-1)*CamInfo.RANGE_WIDTH + w, :) = [h,w];
    end
end

% ProInfo set
ProInfo.HEIGHT = 800;
ProInfo.WIDTH = 1280;
ProInfo.range_mat = [711, 911; 401, 601]; % matlab coordinates
ProInfo.pix_size = 2;
ProInfo.RANGE_HEIGHT = (ProInfo.range_mat(2,2) - ProInfo.range_mat(2,1)) ...
    / ProInfo.pix_size;
ProInfo.RANGE_WIDTH = (ProInfo.range_mat(1,2) - ProInfo.range_mat(1,1)) ...
    / ProInfo.pix_size;
ProInfo.coord_trans = zeros(ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH, 2);
for h = 1:ProInfo.RANGE_HEIGHT
    for w = 1:ProInfo.RANGE_WIDTH
        ProInfo.coord_trans((h-1)*ProInfo.RANGE_WIDTH + w, :) = [h,w];
    end
end
ProInfo.win_size = 4;
ProInfo.RANGE_C_HEIGHT = ceil(ProInfo.RANGE_HEIGHT / ProInfo.win_size);
ProInfo.RANGE_C_WIDTH = ceil(ProInfo.RANGE_WIDTH / ProInfo.win_size);

% FilePath
FilePath.main_file_path = 'E:/Structured_Light_Data/20171104/StatueRotation_part/';
FilePath.optical_path = 'pro/';
FilePath.optical_name = 'pattern_optflow';
FilePath.optical_suffix = '.png';
FilePath.xpro_file_path = 'pro_txt/';
FilePath.xpro_file_name = 'xpro_mat';
FilePath.ypro_file_path = 'pro_txt/';
FilePath.ypro_file_name = 'ypro_mat';
FilePath.pro_file_suffix = '.txt';
FilePath.img_file_path = 'dyna/';
% FilePath.img_file_name = 'pattern_3size4color';
FilePath.img_file_name = 'dyna_mat';
FilePath.img_file_suffix = '.png';
FilePath.output_file_path = 'result/';
FilePath.output_file_name = 'pc';
FilePath.output_file_suffix = '.txt';
pattern = imread([FilePath.main_file_path, 'part_pattern_2size4color0.png']);

% Other ParaSet


ParaSet.M = zeros(ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH, 3);
ParaSet.D = zeros(ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH, 3);
for i = 1:ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH
    x_p = (ProInfo.coord_trans(i,2)-1)*3 + ProInfo.range_mat(1,1);
    y_p = (ProInfo.coord_trans(i,1)-1)*3 + ProInfo.range_mat(2,1);
    tmp_vec = [(x_p - CalibMat.pro(1,3))/CalibMat.pro(1,1); ...
        (y_p - CalibMat.pro(2,3))/CalibMat.pro(2,2); ...
        1];
    ParaSet.M(i,:) = (CalibMat.camMat(:, 1:3)*tmp_vec)';
    ParaSet.D(i,:) = CalibMat.camMat(:, 4)';
end
ParaSet.gradOpt = sparse(ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH, ...
    ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH);
for h = 1:ProInfo.RANGE_HEIGHT
    for w = 1:ProInfo.RANGE_WIDTH
        idx = (h-1)*ProInfo.RANGE_WIDTH + w;
        idx_nbor = [];
        if h-1 >= 1
            idx_nbor = [idx_nbor; (h-1-1)*ProInfo.RANGE_WIDTH + w];
        end
        if h+1 <= ProInfo.RANGE_HEIGHT
            idx_nbor = [idx_nbor; (h+1-1)*ProInfo.RANGE_WIDTH + w];
        end
        if w-1 >= 1
            idx_nbor = [idx_nbor; (h-1)*ProInfo.RANGE_WIDTH + w-1];
        end
        if w+1 <= ProInfo.RANGE_WIDTH
            idx_nbor = [idx_nbor; (h-1)*ProInfo.RANGE_WIDTH + w+1];
        end
        ParaSet.gradOpt(idx, idx) = 4;
        ParaSet.gradOpt(idx, idx_nbor) = -1 * 4 / size(idx_nbor, 1);
    end
end
ParaSet.gradOptC = sparse(ProInfo.RANGE_C_HEIGHT*ProInfo.RANGE_C_WIDTH, ...
    ProInfo.RANGE_C_HEIGHT*ProInfo.RANGE_C_WIDTH);
for h = 1:ProInfo.RANGE_C_HEIGHT
    for w = 1:ProInfo.RANGE_C_WIDTH
        idx = (h-1)*ProInfo.RANGE_C_WIDTH + w;
        idx_nbor = [];
        if h-1 >= 1
            idx_nbor = [idx_nbor; (h-1-1)*ProInfo.RANGE_C_WIDTH + w];
        end
        if h+1 <= ProInfo.RANGE_C_HEIGHT
            idx_nbor = [idx_nbor; (h+1-1)*ProInfo.RANGE_C_WIDTH + w];
        end
        if w-1 >= 1
            idx_nbor = [idx_nbor; (h-1)*ProInfo.RANGE_C_WIDTH + w-1];
        end
        if w+1 <= ProInfo.RANGE_C_WIDTH
            idx_nbor = [idx_nbor; (h-1)*ProInfo.RANGE_C_WIDTH + w+1];
        end
        ParaSet.gradOptC(idx, idx) = 4;
        ParaSet.gradOptC(idx, idx_nbor) = -1 * 4 / size(idx_nbor, 1);
    end
end
ParaSet.lum_radius = 4;

total_frame_num = 40;
max_iter_num = 100;


save('GeneralPara.mat', ...
    'CalibMat', 'CamInfo', 'ProInfo', ...
    'FilePath', 'ParaSet', 'total_frame_num', 'max_iter_num', 'pattern');
