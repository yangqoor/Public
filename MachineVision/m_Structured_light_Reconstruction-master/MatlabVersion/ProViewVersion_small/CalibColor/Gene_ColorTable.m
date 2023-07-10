% % Set parameters
% warning('off');
% clear;
% load ParaEpi.mat

% ParaTable.color = zeros(ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH,1);

% % Prepare for parameter calculation
% fprintf('Pre-processing:\n');

% % Load information
% frame_idx = 0;
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
opt_mat = imread([FilePath.main_file_path, ...
    FilePath.optical_path, ...
    FilePath.optical_name, ...
    num2str(frame_idx), ...
    FilePath.optical_suffix]);
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

% Find correspondence points
fprintf('\tFind correspondence points...');
corres_points = cell(ProInfo.RANGE_HEIGHT, ProInfo.RANGE_WIDTH);
for x_cam = cam_range_mat(1,1):cam_range_mat(1,2)
    for y_cam = cam_range_mat(2,1):cam_range_mat(2,2)
        if mod(ProInfo.pix_size,2) == 1
            xpro_int = round(xpro_mat(y_cam,x_cam)+1);
            ypro_int = round(ypro_mat(y_cam,x_cam)+1);
        else
            xpro_int = round(xpro_mat(y_cam,x_cam)+1.5)-0.5;
            ypro_int = round(ypro_mat(y_cam,x_cam)+1.5)-0.5;
        end
        if (xpro_int < ProInfo.range_mat(1,1)) ...
            || (xpro_int > ProInfo.range_mat(1,2)) ...
            || (ypro_int < ProInfo.range_mat(2,1)) ...
            || (ypro_int > ProInfo.range_mat(2,2))
            continue;
        end
        check_num = (ProInfo.pix_size-1) / 2;
        delta_x = xpro_int - ProInfo.range_mat(1,1);
        delta_y = ypro_int - ProInfo.range_mat(2,1);
        if (mod(delta_x,ProInfo.pix_size) == check_num) ...
            && (mod(delta_y,ProInfo.pix_size) == check_num)
            w_pro = floor(delta_x) / ProInfo.pix_size + 1;
            h_pro = floor(delta_y) / ProInfo.pix_size + 1;
            corres_points{h_pro, w_pro} = [x_cam; y_cam];
        end
    end
end
fprintf('finished.\n');

% Use opt_mat to refine correspondence
% fprintf('\tOptical flow for calibration...');
% template_mat = cell(2,1);
% template_mat{1,1} = [67, 52, 67; 52, 46, 52; 67, 52, 67;];
% template_mat{2,1} = [100, 113, 100; 113, 124, 113; 100, 113, 100];
% template_mat{1,1} = mapminmax(template_mat{1,1});
% template_mat{2,1} = mapminmax(template_mat{2,1});
% for h_pro = 1:ProInfo.RANGE_HEIGHT
%     for w_pro = 1:ProInfo.RANGE_WIDTH
%         xpro_center = (w_pro-1)*3 + ProInfo.range_mat(1,1);
%         ypro_center = (h_pro-1)*3 + ProInfo.range_mat(2,1);
%         t_idx = mod((xpro_center+ypro_center-32-8-4)/3, 2) + 1;
%         match_res = zeros(3, 3);
%         for h_s = -1:1
%             for w_s = -1:1
%                 x_center = corres_points{h_pro, w_pro}(1,1) + w_s;
%                 y_center = corres_points{h_pro, w_pro}(2,1) + h_s;
%                 opt_part = double(opt_mat(y_center-1:y_center+1, ...
%                     x_center-1:x_center+1));
%                 opt_part = mapminmax(opt_part);
%                 match_res(h_s+2,w_s+2) = sum(sum((template_mat{t_idx,1} - opt_part).^2));
%             end
%         end
%         [h_min, w_min] = find(match_res == min(min(match_res)));
%         if size(h_min, 1) > 1
%             continue;
%         end
%         corres_points{h_pro,w_pro} = corres_points{h_pro,w_pro} ...
%             + [h_min-2, w_min-2];
%     end
% end
% fprintf('finished.\n');

% Fill Neighbor valid points
fprintf('\tFilling valid points...');
valid_index = cell(ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH, 3);
valid_index_size = 0;
for h_pro = 1:ProInfo.RANGE_HEIGHT
    for w_pro = 1:ProInfo.RANGE_WIDTH
        pvec_idx = (h_pro-1)*ProInfo.RANGE_WIDTH + w_pro;
        if size(corres_points{h_pro,w_pro},1) == 0
            continue;
        end
        projected_x = corres_points{h_pro,w_pro}(1,1);
        projected_y = corres_points{h_pro,w_pro}(2,1);
        valid_index{pvec_idx,1} = [projected_x, projected_y];

        for dlt_h = -4:1:4
            for dlt_w = -4:1:4
                x_center = round(projected_x);
                y_center = round(projected_y);
                x_cam = x_center + dlt_w;
                y_cam = y_center + dlt_h;

                if (x_cam>=cam_range_mat(1,1)) ...
                    && (x_cam<=cam_range_mat(1,2)) ...
                    && (y_cam>=cam_range_mat(2,1)) ...
                    && (y_cam<=cam_range_mat(2,2)) ...
                    valid_index{pvec_idx,2} = [valid_index{pvec_idx,2}; ...
                        [x_cam, y_cam]];

                    h_cam = y_cam - cam_range_mat(2,1) + 1;
                    w_cam = x_cam - cam_range_mat(1,1) + 1;
                    cvec_idx = (h_cam-1)*cr_width + w_cam;
                    valid_index{pvec_idx,3} = [valid_index{pvec_idx,3}; ...
                        cvec_idx];
                    valid_index_size = valid_index_size + 1;
                end
            end
        end
    end
end
fprintf('finished.\n');

ParaTable.sigma = ones(ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH+1,2);
ParaTable.sigma = ParaTable.sigma * 1.5;

% Fill information
fprintf('\tFill data mat...');
data_mat_index = zeros(valid_index_size, 2);
data_mat_value = zeros(valid_index_size, 1);
now_idx = 0;
for pvec_idx = 1:ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH
    if size(valid_index{pvec_idx,1},1) == 0
        continue;
    end
    projected_x = valid_index{pvec_idx,1}(1);
    projected_y = valid_index{pvec_idx,1}(2);
    for p_num = 1:size(valid_index{pvec_idx,2},1)
        cvec_idx = valid_index{pvec_idx,3}(p_num);
        x_cam = valid_index{pvec_idx,2}(p_num,1);
        y_cam = valid_index{pvec_idx,2}(p_num,2);
        sigma_x = ParaTable.sigma(pvec_idx,1);
        sigma_y = ParaTable.sigma(pvec_idx,2);
        exp_val = - 1/(2*sigma_x^2) * (x_cam - projected_x)^2 ...
            - 1/(2*sigma_y^2) * (y_cam - projected_y)^2;
        now_idx = now_idx + 1;
        data_mat_index(now_idx,:) = [cvec_idx,pvec_idx];
        data_mat_value(now_idx,1) = 1/(2*pi*sigma_x*sigma_y) ...
            * exp(exp_val);
    end
end
% data_mat_index = [data_mat_index; ...
%     [(1:cr_height*cr_width)', ...
%     ones(cr_height*cr_width,1)*(ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH+1)]];
% data_mat_value = [data_mat_value; ...
%     ones(cr_height*cr_width,1)];
data_mat = sparse(data_mat_index(:,1), data_mat_index(:,2), data_mat_value);
data_mat(cr_height*cr_width, ProInfo.RANGE_HEIGHT*ProInfo.RANGE_WIDTH) = 0;
fprintf('finished.\n');

% Optimization
fprintf('\tLeast squares...')
envir_light = 15;
tmp_color = data_mat \ (cam_vec-envir_light);
fprintf('finished.\n');

% Storage
cam_vec_est = data_mat * tmp_color + envir_light;
error_value = norm((cam_vec_est-cam_vec));
fprintf('\tError=%.2f\n', error_value);

ParaTable.color = tmp_color;
save(['ColorPara', num2str(frame_idx), '.mat'], 'ParaTable');

% Show result
cam_mat_est = reshape(cam_vec_est, cr_width, cr_height)';
imshow(uint8([cam_mat, cam_mat_est]));
