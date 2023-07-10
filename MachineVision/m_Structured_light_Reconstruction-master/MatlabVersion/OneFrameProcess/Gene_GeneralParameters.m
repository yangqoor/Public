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
CalibMat.camMat = [CalibMat.cam, zeros(3,1)];
CalibMat.proMat = CalibMat.pro * [CalibMat.rot, CalibMat.trans];

% CamInfo set
CamInfo.HEIGHT = 1024;
CamInfo.WIDTH = 1280;
CamInfo.range_mat = [434, 825+40; 463, 809];
CamInfo.R_HEIGHT = CamInfo.range_mat(2,2) - CamInfo.range_mat(2,1) + 1;
CamInfo.R_WIDTH = CamInfo.range_mat(1,2) - CamInfo.range_mat(1,1) + 1;
CamInfo.coord_trans = zeros(CamInfo.R_HEIGHT*CamInfo.R_WIDTH, 2);
for h = 1:CamInfo.R_HEIGHT
    for w = 1:CamInfo.R_WIDTH
        CamInfo.coord_trans((h-1)*CamInfo.R_WIDTH + w, :) = [h,w];
    end
end
CamInfo.win_rad = 5;

% ProInfo set
ProInfo.HEIGHT = 800;
ProInfo.WIDTH = 1280;
ProInfo.range_mat = [711, 911; 401, 601]; % matlab coordinates

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
ParaSet.M = zeros(CamInfo.R_HEIGHT*CamInfo.R_WIDTH, 3);
ParaSet.D = zeros(CamInfo.R_HEIGHT*CamInfo.R_WIDTH, 3);
for h_cam = 1:CamInfo.R_HEIGHT
    for w_cam = 1:CamInfo.R_WIDTH
        cvec_idx = (h_cam-1)*CamInfo.R_WIDTH + w_cam;
        x_cam = w_cam + CamInfo.range_mat(1,1) - 1 - 1;
        y_cam = h_cam + CamInfo.range_mat(2,1) - 1 - 1;
        tmp_vec = [(x_cam - CalibMat.cam(1,3)) / CalibMat.cam(1,1); ...
            (y_cam - CalibMat.cam(2,3)) / CalibMat.cam(2,2); ...
            1];
        ParaSet.M(cvec_idx,:) = (CalibMat.proMat(:,1:3)*tmp_vec)';
        ParaSet.D(cvec_idx,:) = CalibMat.proMat(:,4)';
    end
end
ParaSet.lumi_thred = 60;

total_frame_num = 40;

save('GeneralPara.mat', ...
    'CalibMat', 'CamInfo', 'ProInfo', ...
    'FilePath', 'ParaSet', 'total_frame_num', 'pattern');
