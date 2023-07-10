kWinRad = 7;
kLumiThred = 40;
max_depth_val = 50;
min_depth_val = 35;

% Pattern: pattern.png -> pattern.txt
pat_img = imread('pattern.png');
pat_img_d = double(pat_img);
save('pattern.txt', 'pat_img_d', '-ascii');

% Weight: weight.txt
weight_mat = zeros(800, 1280);
for h = 2:2:800
  for w = 2:2:1280
    weight_mat(h, w) = 1.0;
  end
end
save('weight.txt', 'weight_mat', '-ascii');

% Image: img.png
img_obs = imread('dyna_mat33.png');
img_obs_d = double(img_obs);
imwrite(img_obs, 'img.png');

% Mask: mask.txt. According to max & min val
mask_mat = zeros(1024, 1280);
for h = kWinRad+1:1024-kWinRad
  for w = kWinRad+1:1280-kWinRad
    max_val = max(max(img_obs_d(h-kWinRad:h+kWinRad, w-kWinRad:w+kWinRad)));
    min_val = min(min(img_obs_d(h-kWinRad:h+kWinRad, w-kWinRad:w+kWinRad)));
    if max_val - min_val > kLumiThred
      mask_mat(h, w) = 1;
    end
  end
end
% TODO: FloodFill Method

% Depth: from last depth_val
last_depth_mat = load('depth_mat32.txt');
now_depth_mat = zeros(1024, 1280);
for h = 1:1024
  for w = 1:1280
    if mask_mat(h, w) < 1
      continue;
    end
    if (last_depth_mat(h, w) > min_depth_val) && (last_depth_mat(h,w) < max_depth_val)
      now_depth_mat(h, w) = last_depth_mat(h, w);
    else
      now_depth_mat(h, w) = (max_depth_val + min_depth_val) / 2;
    end
  end
end

% EpiA, EpiB (pass)
% Mat M & D
cam_mat_0 = [2428.270501026523, 0, 717.1879617522386;
    0, 2425.524847530806, 419.6450731465209;
    0, 0, 1 ];
cam_mat_1 = [2432.058972474525, 0, 762.2933947666461;
    0, 2435.900798664577, 353.2790048217345;
    0, 0, 1];
rot_mat = [];
trans_vec = [];
cam_0_matrix = [cam_mat_0, zeros(3, 1)];
cam_1_matrix = cam_mat_1 * [(rot_mat)', -trans_vec];
mat_M = zeros(3, 1024:1280);
mat_D = zeros(3, 1024:1280);
dx = cam_mat_0(1, 3); fx = cam_mat_0(1, 1);
dy = cam_mat_0(2, 3); fy = cam_mat_0(2, 2);
for h = 1:1024
  for w = 1:1280
    idx_k = (h-1)*1280 + w;
    tmp_vec = [(w - 1 - dx) / fx; (h - 1 - dy) / fy; 1.0];
    mat_M(idx_k, :) = cam_1_matrix(:, 1:3) * tmp_vec;
    mat_D(idx_k, :) = cam_1_matrix(:, 4);
  end
end
save('Mat_M.txt', 'mat_M', '-ascii');
save('Mat_D.txt', 'mat_D', '-ascii');