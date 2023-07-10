clear;

% CamInfo set
CamInfo.HEIGHT = 1024;
CamInfo.WIDTH = 1280;
ProInfo.HEIGHT = 800;
ProInfo.WIDTH = 1280;

% FilePath
FilePath.main_file_path = 'E:/Structured_Light_Data/20171121/EpiLineCalib/';
FilePath.xpro_file_path = 'pro/';
FilePath.xpro_file_name = 'xpro_mat';
FilePath.ypro_file_path = 'pro/';
FilePath.ypro_file_name = 'ypro_mat';
FilePath.pro_file_suffix = '.txt';
FilePath.img_file_path = 'dyna/';
FilePath.img_file_name = 'dyna_mat';
FilePath.img_file_suffix = '.png';

total_frame_num = 20;

save('GeneEpilinePara.mat', ...
    'CamInfo', 'ProInfo', 'FilePath', 'total_frame_num');
