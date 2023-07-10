clear;
load GeneralPara.mat;
load EpipolarPara.mat;
load GaussPara.mat

% Load images
camera_image = imread([main_file_path, img_file_path, ...
    img_file_name, num2str(0), img_file_suffix]);
xpro_mat = load([main_file_path, xpro_file_path, ...
    xpro_file_name, num2str(0), pro_file_suffix]);
ypro_mat = load([main_file_path, ypro_file_path, ...
    ypro_file_name, num2str(0), pro_file_suffix]);

% Intersection For xpro_mat & ypro_mat
intersect_range = [253, 1037; 210, 746];
for h = intersect_range(2, 1):intersect_range(2, 2)
    for w = intersect_range(1, 1):intersect_range(1, 2)
        if xpro_mat(h, w) < 0
            xpro_mat(h, w) = (xpro_mat(h, w-1) + xpro_mat(h, w+1)) / 2;
        end
        if ypro_mat(h, w) < 0
            ypro_mat(h, w) = (ypro_mat(h-1, w) + ypro_mat(h+1, w)) / 2;
        end
    end
end

% Fill valid_mask
valid_mask = zeros(CAMERA_HEIGHT, CAMERA_WIDTH);
for h = 1:CAMERA_HEIGHT
    for w = 1:CAMERA_WIDTH
        if (xpro_mat(h, w) > pro_range(1, 1) - 1) ...
            && (xpro_mat(h, w) < pro_range(1, 2) + 1) ...
            && (ypro_mat(h, w) > pro_range(2, 1) - 1) ...
            && (ypro_mat(h, w) < pro_range(2, 2) + 1)
            valid_mask(h, w) = 1;
        end
    end
end
search_range = intersect_range;
valid_mask(831:end, :) = 0;

% Fill Correspondence mat
corres_mat = cell(50, 50);
for h = search_range(2, 1):search_range(2, 2)
    for w = search_range(1, 1):search_range(1, 2)
        if valid_mask(h, w) == 0
            continue;
        end
        x_val = xpro_mat(h, w);
        y_val = ypro_mat(h, w);
        if (mod(round(x_val) - 32, 3) == 1) && (mod(round(y_val) - 8, 3) == 1)
            h_i = (round(y_val) - pro_range(2, 1)) / 3 + 1;
            w_i = (round(x_val) - pro_range(1, 1)) / 3 + 1;
            corres_mat{h_i, w_i} = [h; w];
        end
    end
end

% Fill show_mat
show_mat = zeros(CAMERA_HEIGHT, CAMERA_WIDTH, 3);
show_mat(:, :, 1) = double(camera_image) / 255;
show_mat(:, :, 2) = show_mat(:, :, 1);
show_mat(:, :, 3) = show_mat(:, :, 1);
for h = 1:50
    for w = 1:50
        if size(corres_mat{h, w}, 1) == 0
            continue;
        end
        h_c = corres_mat{h, w}(1, 1);
        w_c = corres_mat{h, w}(2, 1);
        show_mat(h_c, w_c, :) = 0.0;
        show_mat(h_c, w_c, 1) = 1.0;
    end
end

% Gaussian Mats
gauss_mats = cell(6, 1);
color_set = [0, 114, 161, 197, 228, 255];
for i = 1:6
    gauss_mats{i, 1} = zeros(11, 11);
    if color_set(i) > 0
        for h = 1:11
            for w = 1:11
                C = para_set(i, 1) * 1.5^2;
                sg_1 = para_set(i, 2) * 1.5;
                sg_2 = para_set(i, 3) * 1.5;
                x = w - 6;
                y = h - 6;
                gauss_mats{i, 1}(h, w) = C / (2*pi * sg_1 * sg_2) ...
                    *exp(-1/2*(x^2/sg_1^2 + y^2/sg_2^2));
            end
        end
    end
end

% Fill Generate_mat
gene_mat = zeros(CAMERA_HEIGHT, CAMERA_WIDTH);
gene_mat = gene_mat + 20; % Environment light bias
% -60 / 35
for h_p = 1:50
    for w_p = 1:50
        x_p = pro_range(1, 1) + (w_p - 1) * 3 + 1;
        y_p = pro_range(2, 1) + (h_p - 1) * 3 + 1;
        color_index = round((pattern(y_p, x_p) - 60) / 35);
        if color_index > 0
            x_c = corres_mat{h_p, w_p}(2, 1);
            y_c = corres_mat{h_p, w_p}(1, 1);
            gene_mat(y_c-5:y_c+5, x_c-5:x_c+5) = gene_mat(y_c-5:y_c+5, x_c-5:x_c+5) ...
                + gauss_mats{color_index, 1};
        end
    end
end
