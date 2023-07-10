% Set parameters
warning('off');
clear;
load ParaEpi.mat

% ParaTable.color = zeros(ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH,1);

% Prepare for parameter calculation
fprintf('Pre-processing:\n');

% Load information
frame_idx = 0;
fprintf('\tLoad information...');
cam_total_mat = double(imread([FilePath.main_file_path, ...
    FilePath.img_file_path, ...
    FilePath.img_file_name, ...
    num2str(frame_idx), ...
    FilePath.img_file_suffix]));
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
fprintf('finished.\n');

% Search range_area
fprintf('\tSearching area...');
cam_range_mat = [CamInfo.WIDTH, 1; CamInfo.HEIGHT, 1];
for h = 1:CamInfo.HEIGHT
    for w = 1:CamInfo.WIDTH
        x_pro = xpro_mat(h,w) + 1;
        y_pro = ypro_mat(h,w) + 1;
        if (x_pro >= ProInfo.range_mat(1,1)-4) ...
            && (x_pro <= ProInfo.range_mat(1,2)+4) ...
            && (y_pro >= ProInfo.range_mat(2,1)-4) ...
            && (y_pro <= ProInfo.range_mat(2,2)+4)
            if w < cam_range_mat(1,1)
                cam_range_mat(1,1) = w;
            end
            if w > cam_range_mat(1,2)
                cam_range_mat(1,2) = w;
            end
            if h < cam_range_mat(2,1)
                cam_range_mat(2,1) = h;
            end
            if h > cam_range_mat(2,2)
                cam_range_mat(2,2) = h;
            end
        end
    end
end
cr_height = cam_range_mat(2,2) - cam_range_mat(2,1) + 1;
cr_width = cam_range_mat(1,2) - cam_range_mat(1,1) + 1;
cam_mat = cam_total_mat(cam_range_mat(2,1):cam_range_mat(2,2), ...
    cam_range_mat(1,1):cam_range_mat(1,2));
cam_vec = reshape(cam_mat', cr_height*cr_width, 1);
fprintf('finished.\n');

% Intersect
fprintf('\tIntersect...');
for w = cam_range_mat(1,1):cam_range_mat(1,2)
    for h = cam_range_mat(2,1):cam_range_mat(2,2)
        if xpro_mat(h,w) < 0
            xpro_mat(h,w) = (xpro_mat(h,w-1) + xpro_mat(h,w+1)) / 2;
        end
        if ypro_mat(h,w) < 0
            ypro_mat(h,w) = (ypro_mat(h-1,w) + ypro_mat(h+1,w)) / 2;
        end
    end
end
fprintf('finished.\n');

% Fill Neighbor valid points
fprintf('\tFilling valid points...');
valid_index = cell(cr_height*cr_width, 3);
for h_cam = 1:cr_height
    for w_cam = 1:cr_width
        x_cam = w_cam + cam_range_mat(1,1) - 1;
        y_cam = h_cam + cam_range_mat(2,1) - 1;
        cvec_idx = (h_cam-1)*cr_width + w_cam;
        projected_x = xpro_mat(y_cam,x_cam) + 1;
        projected_y = ypro_mat(y_cam,x_cam) + 1;
        valid_index{cvec_idx,1} = [projected_x, projected_y];

        for dlt_h = -4:1:4
            for dlt_w = -4:1:4
                w_center = round((projected_x-ProInfo.range_mat(1,1))/3+1);
                h_center = round((projected_y-ProInfo.range_mat(2,1))/3+1);
                w_pro = w_center + dlt_w;
                h_pro = h_center + dlt_h;
                x_pro = (w_pro-1)*3 + ProInfo.range_mat(1,1);
                y_pro = (h_pro-1)*3 + ProInfo.range_mat(2,1);

                if (h_pro>=1) && (h_pro<=ProInfo.RANGE_HEIGHT) ...
                    && (w_pro>=1) && (w_pro<=ProInfo.RANGE_WIDTH)
                    pvec_idx = (h_pro-1)*ProInfo.RANGE_WIDTH + w_pro;
                    valid_index{cvec_idx,2} = [valid_index{cvec_idx,2}; ...
                        [x_pro, y_pro]];
                    valid_index{cvec_idx,3} = [valid_index{cvec_idx,3}; ...
                        pvec_idx];
                end
            end
        end
    end
end
fprintf('finished.\n');

ParaTable.sigma = ones(ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH+1,2);
ParaTable.sigma = ParaTable.sigma * 1.505;

% Fill information
fprintf('\tFill data mat...');
data_mat = zeros(cr_height*cr_width, ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH+1);
data_mat(:,end) = 1;
for cvec_idx = 1:cr_height*cr_width
    projected_x = valid_index{cvec_idx,1}(1);
    projected_y = valid_index{cvec_idx,1}(2);
    for p_num = 1:size(valid_index{cvec_idx,2},1)
        pvec_idx = valid_index{cvec_idx,3}(p_num);
        x_pro = valid_index{cvec_idx,2}(p_num,1);
        y_pro = valid_index{cvec_idx,2}(p_num,2);
        sigma_x = ParaTable.sigma(pvec_idx,1);
        sigma_y = ParaTable.sigma(pvec_idx,2);
        exp_val = - 1/(2*sigma_x^2) * (x_pro - projected_x)^2 ...
            - 1/(2*sigma_y^2) * (y_pro - projected_y)^2;
        data_mat(cvec_idx,pvec_idx) = 1/(2*pi*sigma_x*sigma_y) ...
            * exp(exp_val);
    end
end
fprintf('finished.\n');

% Optimization
fprintf('\tLeast squares...')
sDataMat = sparse(data_mat);
tmp_color = sDataMat \ (cam_vec);
fprintf('finished.\n');

% Storation
cam_vec_est = sDataMat * tmp_color;
error_value = norm((cam_vec_est-cam_vec));
fprintf('\tError=%.2f\n', error_value);

ParaTable.color = tmp_color;
save(['ColorPara', num2str(frame_idx), '.mat'], 'ParaTable');

% Show result
cam_mat_est = reshape(cam_vec_est, cr_width, cr_height)';
imshow(uint8([cam_mat, cam_mat_est]));
