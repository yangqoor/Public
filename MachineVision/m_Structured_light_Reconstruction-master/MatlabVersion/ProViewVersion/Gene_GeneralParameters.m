clear;

% Cam Pro Inner parameters
CalibMat.cam = [ 2460.98, 0.0, 639.50;
    0.0, 2462.24, 511.50;
    0.0, 0.0, 1.0];
CalibMat.pro = [ 1808.35, 0.0, 787.53;
    0.0, 1813.76, 649.98;
    0.0, 0.0, 1.0];
CalibMat.rot = [0.9826, 0.009897, -0.1856;
    -0.02213, 0.9977, -0.06398;
    0.1845, 0.06697, 0.9805];
CalibMat.trans = [9.4886;
    -1.6272;
    3.3267];
CalibMat.proMat = [CalibMat.pro, zeros(3,1)];
CalibMat.camMat = CalibMat.cam * [inv(CalibMat.rot), -CalibMat.trans];

% CamInfo set
CamInfo.HEIGHT = 1024;
CamInfo.WIDTH = 1280;
CamInfo.range_mat = [512, 807; 442, 704];
CamInfo.RANGE_HEIGHT = CamInfo.range_mat(2,2) - CamInfo.range_mat(2,1) + 1;
CamInfo.RANGE_WIDTH = CamInfo.range_mat(1,2) - CamInfo.range_mat(1,1) + 1;

% ProInfo set
ProInfo.HEIGHT = 800;
ProInfo.WIDTH = 1280;
ProInfo.range_mat = [769, 919; 445, 595]; % matlab coordinates
ProInfo.RANGE_HEIGHT = ProInfo.range_mat(2,2) - ProInfo.range_mat(2,1) + 1;
ProInfo.RANGE_WIDTH = ProInfo.range_mat(1,2) - ProInfo.range_mat(1,1) + 1;

% FilePath
FilePath.main_file_path = 'E:/Structured_Light_Data/20171008/PartSphereMovement2/';
FilePath.optical_path = 'pro/';
FilePath.optical_name = 'pattern_optflow';
FilePath.optical_suffix = '.png';
FilePath.xpro_file_path = 'pro_txt/';
FilePath.xpro_file_name = 'xpro_mat';
FilePath.ypro_file_path = 'pro_txt/';
FilePath.ypro_file_name = 'ypro_mat';
FilePath.pro_file_suffix = '.txt';
FilePath.img_file_path = 'dyna/';
% FilePath.img_file_name = 'pattern_3size6color';
FilePath.img_file_name = 'dyna_mat';
FilePath.img_file_suffix = '.png';
FilePath.output_file_path = 'result/';
FilePath.output_file_name = 'pc';
FilePath.output_file_suffix = '.txt';

% Other ParaSet
ParaSet.coord_cam = zeros(CamInfo.RANGE_HEIGHT*CamInfo.RANGE_WIDTH, 2);
for h = 1:CamInfo.RANGE_HEIGHT
    for w = 1:CamInfo.RANGE_WIDTH
        ParaSet.coord_cam((h-1)*CamInfo.RANGE_WIDTH + w, :) = [h, w];
    end
end
ParaSet.coord_pro = zeros(ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH, 2);
for h = 1:ProInfo.RANGE_HEIGHT
    for w = 1:ProInfo.RANGE_WIDTH
        ParaSet.coord_pro((h-1)*ProInfo.RANGE_WIDTH + w, :) = [h, w];
    end
end
ParaSet.M = zeros(ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH, 3);
ParaSet.D = zeros(ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH, 3);
for i = 1:ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH
    x_p = (ParaSet.coord_pro(i,2)-1)*3 + ProInfo.range_mat(1,1);
    y_p = (ParaSet.coord_pro(i,1)-1)*3 + ProInfo.range_mat(2,1);
    tmp_vec = [(x_p - CalibMat.pro(1,3))/CalibMat.pro(1,1); ...
        (y_p - CalibMat.pro(2,3))/CalibMat.pro(2,2); ...
        1];
    ParaSet.M(i,:) = (CalibMat.camMat(:, 1:3)*tmp_vec)';
    ParaSet.D(i,:) = CalibMat.camMat(:, 4)';
end
% ParaSet.gauss = [0,1,1;
%     435.17, 1.471, 1.471;
%     709.79, 1.329, 1.329;
%     1043.29, 1.308, 1.308;
%     1382.99, 1.254, 1.254;
%     1728.74, 1.254, 1.254] * 1;
% sigma = [2.0; 2.0; 2.0; 2.0; 2.0; 2.0];
% color = [47; 91; 111; 145; 156; 208];
% color = [0; 9; 14; 21; 28; 36];
% ParaSet.gauss = zeros(6, 3);
% ParaSet.gauss(:, 1) = color.*(sigma.^2) * 2 * pi;
% ParaSet.gauss(:, 2:3) = [sigma, sigma];
% ParaSet.gauss(:, 1) = ParaSet.gauss(:, 1) * 1;

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

total_frame_num = 20;
max_iter_num = 100;
pattern = imread([FilePath.main_file_path, 'part_pattern_3size4color.png']);

save('GeneralPara.mat', ...
    'CalibMat', 'CamInfo', 'ProInfo', ...
    'FilePath', 'ParaSet', 'total_frame_num', 'max_iter_num', 'pattern');
