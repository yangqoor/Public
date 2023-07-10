clear;

% CamInfo set
CamInfo.HEIGHT = 1024;
CamInfo.WIDTH = 1280;
% CamInfo.inter_range = [128, 1092; 252, 768];

% ProInfo set
% ProInfo set
ProInfo.HEIGHT = 800;
ProInfo.WIDTH = 1280;
ProInfo.range_mat = [711, 911; 401, 601]; % matlab coordinates
ProInfo.pix_size = 2;
ProInfo.RANGE_HEIGHT = (ProInfo.range_mat(2,2) - ProInfo.range_mat(2,1)) ...
    / ProInfo.pix_size;
ProInfo.RANGE_WIDTH = (ProInfo.range_mat(1,2) - ProInfo.range_mat(1,1)) ...
    / ProInfo.pix_size;

% FilePath
FilePath.main_file_path = 'E:/Structured_Light_Data/20171104/EpipolarCalib/';
FilePath.optical_path = 'pro/';
FilePath.optical_name = 'pattern_optflow';
FilePath.optical_suffix = '.png';
FilePath.xpro_file_path = 'pro_txt/';
FilePath.xpro_file_name = 'xpro_mat';
FilePath.ypro_file_path = 'pro_txt/';
FilePath.ypro_file_name = 'ypro_mat';
FilePath.pro_file_suffix = '.txt';
FilePath.img_file_path = 'dyna/';
FilePath.img_file_name = 'part_pattern_2size4color';
% FilePath.img_file_name = 'dyna_mat';
FilePath.img_file_suffix = '.png';


total_frame_num = 20;

save('ParaEpi.mat', ...
    'CamInfo', 'ProInfo', 'FilePath', 'total_frame_num');
