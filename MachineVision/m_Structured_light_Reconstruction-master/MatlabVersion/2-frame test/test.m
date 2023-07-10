% Load parameters
clear;
load EpipolarPara.mat
load GeneralPara.mat

% Read information of 1st frame
cam_mats = cell(total_frame_num, 1);
depth_mats = cell(total_frame_num, 1);
valid_mats = cell(total_frame_num, 1);
corres_mats = cell(total_frame_num, 1);
[depth_mats{1,1}, corres_mats{1,1}, optical_mat] = fun_InitDepthMat(FilePath, ...
    CamInfo, ...
    ProInfo, ...
    ParaSet);
tmp_image = double(imread([FilePath.main_file_path, ...
    FilePath.img_file_path, ...
    FilePath.img_file_name, ...
    num2str(1), ...
    FilePath.img_file_suffix]));
cam_mats{1, 1} = tmp_image(CamInfo.cam_range(2,1):CamInfo.cam_range(2,2), ...
    CamInfo.cam_range(1,1):CamInfo.cam_range(1,2));
tmp_image = double(imread([FilePath.main_file_path, ...
    FilePath.img_file_path, ...
    FilePath.img_file_name, ...
    num2str(12), ...
    FilePath.img_file_suffix]));
cam_mats{2, 1} = tmp_image(CamInfo.cam_range(2,1):CamInfo.cam_range(2,2), ...
    CamInfo.cam_range(1,1):CamInfo.cam_range(1,2));
opt_mat = optical_mat(CamInfo.cam_range(2,1):CamInfo.cam_range(2,2), ...
    CamInfo.cam_range(1,1):CamInfo.cam_range(1,2));

show_mask_true = zeros(CamInfo.RANGE_HEIGHT, CamInfo.RANGE_WIDTH);
for h = 1:ProInfo.RANGE_HEIGHT
    for w = 1:ProInfo.RANGE_WIDTH
        h_c = corres_mats{1,1}{h,w}(1,1) - CamInfo.cam_range(2,1) + 1;
        w_c = corres_mats{1,1}{h,w}(1,2) - CamInfo.cam_range(1,1) + 1;
        show_mask_true(h_c, w_c) = 1;
    end
end

epi_corres_mat = cell(ProInfo.RANGE_HEIGHT,ProInfo.RANGE_WIDTH);
para_corres_mat = cell(ProInfo.RANGE_HEIGHT,ProInfo.RANGE_WIDTH);
for h_pro = 1:ProInfo.RANGE_HEIGHT
    for w_pro = 1:ProInfo.RANGE_WIDTH
        pvec_idx = (h_pro-1)*ProInfo.RANGE_WIDTH+w_pro;
        A = EpiLine.lineA(h_pro, w_pro);
        B = EpiLine.lineB(h_pro, w_pro);
        M = ParaSet.M(pvec_idx,:);
        D = ParaSet.D(pvec_idx,:);
        depth = depth_mats{1,1}(h_pro,w_pro);
        projected_x = corres_mats{1,1}{h_pro,w_pro}(1,2);
        projected_y = round(-A/B * projected_x + 1/B);
        para_y = round((M(2)*depth + D(2)) / (M(3)*depth + D(3)));
        epi_corres_mat{h_pro,w_pro} = [projected_y, projected_x];
        para_corres_mat{h_pro,w_pro} = [para_y, projected_x];
    end
end
show_mask_epi = zeros(CamInfo.RANGE_HEIGHT, CamInfo.RANGE_WIDTH);
show_mask_para = zeros(CamInfo.RANGE_HEIGHT, CamInfo.RANGE_WIDTH);
for h = 1:ProInfo.RANGE_HEIGHT
    for w = 1:ProInfo.RANGE_WIDTH
        h_c = epi_corres_mat{h,w}(1,1) - CamInfo.cam_range(2,1) + 1;
        w_c = epi_corres_mat{h,w}(1,2) - CamInfo.cam_range(1,1) + 1;
        show_mask_epi(h_c, w_c) = 1;
        h_c = para_corres_mat{h,w}(1,1) - CamInfo.cam_range(2,1) + 1;
        w_c = para_corres_mat{h,w}(1,2) - CamInfo.cam_range(1,1) + 1;
        show_mask_para(h_c, w_c) = 1;
    end
end

color_opt_mat = zeros(CamInfo.RANGE_HEIGHT, CamInfo.RANGE_WIDTH, 3);
color_opt_mat(:,:,1) = opt_mat;
color_opt_mat(:,:,2) = color_opt_mat(:,:,1);
color_opt_mat(:,:,3) = color_opt_mat(:,:,2);
for h_c = 1:CamInfo.RANGE_HEIGHT
    for w_c = 1:CamInfo.RANGE_WIDTH
        if show_mask_epi(h_c, w_c)
            color_opt_mat(h_c,w_c,1) = 255.0;
            color_opt_mat(h_c,w_c,2) = 0.0;
            color_opt_mat(h_c,w_c,3) = 0.0;
        end
    end
end
