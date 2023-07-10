% Set parameters
warning('off');
clear;
load GeneralParaEpi.mat

% Create lineA, lineB, lineC
EpiLine.lineA = zeros(ProInfo.RANGE_HEIGHT, ProInfo.RANGE_WIDTH);
EpiLine.lineB = zeros(size(EpiLine.lineA));
EpiLine.lineC = ones(size(EpiLine.lineA));
xdis_threhold = 10;

% Fill valid points
valid_points = cell(ProInfo.RANGE_HEIGHT, ProInfo.RANGE_WIDTH);

template_mat = cell(2, 1);
template_mat{1,1} = [67, 52, 67; 52, 46, 52; 67, 52, 67;];
template_mat{2,1} = [100, 113, 100; 113, 124, 113; 100, 113, 100];
template_mat{1,1} = mapminmax(template_mat{1,1});
template_mat{2,1} = mapminmax(template_mat{2,1});

for frame_idx = 0:total_frame_num-1
    fprintf(['F', num2str(frame_idx), ': ']);

    % Load and Intersect
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
    img_mat = imread([FilePath.main_file_path, ...
        FilePath.img_file_path, ...
        FilePath.img_file_name, ...
        num2str(frame_idx), ...
        FilePath.img_file_suffix]);
    for h = CamInfo.range_mat(2,1):CamInfo.range_mat(2,2)
        for w = CamInfo.range_mat(1,1):CamInfo.range_mat(1,2)
            if xpro_mat(h,w) < 0
                xpro_mat(h,w) = (xpro_mat(h,w-1) + xpro_mat(h,w+1)) / 2;
            end
            if ypro_mat(h,w) < 0
                ypro_mat(h,w) = (ypro_mat(h-1,w) + ypro_mat(h+1,w)) / 2;
            end
        end
    end
    fprintf('L;');

    % Find Correspondence and refinement
    tmp_valid_points = cell(ProInfo.RANGE_HEIGHT, ProInfo.RANGE_WIDTH);
    error_value = ones(ProInfo.RANGE_HEIGHT, ProInfo.RANGE_WIDTH)*255;
    for h = CamInfo.range_mat(2,1):CamInfo.range_mat(2,2)
        for w = CamInfo.range_mat(1,1):CamInfo.range_mat(1,2)
            if mod(ProInfo.pix_size,2) == 1
                xpro_int = round(xpro_mat(h, w)+1);
                ypro_int = round(ypro_mat(h, w)+1);
            else
                xpro_int = round(xpro_mat(h, w)+1.5)-0.5;
                ypro_int = round(ypro_mat(h, w)+1.5)-0.5;
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
                w_i = floor(delta_x) / ProInfo.pix_size + 1;
                h_i = floor(delta_y) / ProInfo.pix_size + 1;
                error_val = (xpro_int-xpro_mat(h,w)-1)^2 + (ypro_int-ypro_mat(h,w)-1)^2;
                if error_val < error_value(h_i,w_i)
                    error_value(h_i,w_i) = error_val;
                    tmp_valid_points{h_i, w_i} = [w, h];
                end
            end
        end
    end

    % Use optical flow for refinement
%     for h = 1:ProInfo.RANGE_HEIGHT
%         for w = 1:ProInfo.RANGE_WIDTH
%             xpro_center = (w-1)*3 + ProInfo.pro_range(1, 1);
%             ypro_center = (h-1)*3 + ProInfo.pro_range(2, 1);
%             tpl_idx = mod((xpro_center+ypro_center-32-8-4)/3, 2) + 1;
%             match_res = zeros(3, 3);
%             if size(tmp_valid_points{h,w},1) == 0
%                 continue
%             end
%             for h_s = -1:1
%                 for w_s = -1:1
%                     w_center = tmp_valid_points{h, w}(1, 1) + w_s;
%                     h_center = tmp_valid_points{h, w}(1, 2) + h_s;
%                     img_part = double(opt_mat(h_center-1:h_center+1, w_center-1:w_center+1));
%                     img_part = mapminmax(img_part);
%                     match_res(h_s+2, w_s+2) = sum(sum((template_mat{tpl_idx, 1} - img_part).^2));
%                 end
%             end
%             [h_res, w_res] = find(match_res == min(min(match_res)));
% %             h_res = 3;
% %             w_res = 3;
%             valid_points{h, w} = [valid_points{h, w}; ...
%                 [tmp_valid_points{h, w}(1, 1) + w_res - 2, ...
%                 tmp_valid_points{h, w}(1, 2) + h_res - 2]];
%         end
%     end
%     fprintf('O;');

    for h_pro = 1:ProInfo.RANGE_HEIGHT
        for w_pro = 1:ProInfo.RANGE_WIDTH
            valid_points{h_pro,w_pro} = [valid_points{h_pro,w_pro}; ...
                tmp_valid_points{h_pro,w_pro}];
        end
    end

    show_mat = zeros(CamInfo.HEIGHT, CamInfo.WIDTH, 3);
    show_mat(:, :, 1) = double(img_mat) / 255;
    show_mat(:, :, 2) = show_mat(:, :, 1);
    show_mat(:, :, 3) = show_mat(:, :, 1);
    for h = 1:ProInfo.RANGE_HEIGHT
        for w = 1:ProInfo.RANGE_WIDTH
            if size(valid_points{h,w},1) == 0
                continue;
            end
            h_c = valid_points{h, w}(end, 2);
            w_c = valid_points{h, w}(end, 1);
            show_mat(h_c, w_c, :) = 0.0;
            show_mat(h_c, w_c, 1) = 1.0;
        end
    end
    imshow(show_mat);

    fprintf('.\n')
end
fprintf('Calculation...\n');

% Fill valid mat according to valid_points
valid_mat = zeros(CamInfo.HEIGHT, CamInfo.WIDTH);
for h = 1:ProInfo.RANGE_HEIGHT
    for w = 1:ProInfo.RANGE_WIDTH
        if size(valid_points{h, w}, 1) == 0
            continue;
        end
        xmax_val = max(valid_points{h, w}(:, 1));
        xmin_val = min(valid_points{h, w}(:, 1));
        if xmax_val - xmin_val > xdis_threhold
            vecX = valid_points{h, w} \ ones(size(valid_points{h, w}, 1), 1);
            valid_mat(h, w) = 1;
            EpiLine.lineA(h, w) = vecX(1);
            EpiLine.lineB(h, w) = vecX(2);
        end
    end
end

save('ParaEpi.mat', 'EpiLine');
