% CalibMat.cam_0 = [ 2432.058972474525, 0, 762.2933947666461;
%   0, 2435.900798664577, 353.2790048217345;
%   0, 0, 1];
% CalibMat.cam_1 = [ 2428.270501026523, 0, 717.1879617522386;
%   0, 2425.524847530806, 419.6450731465209;
%   0, 0, 1];
% CalibMat.rot = [0.9991682873520409, 0.01604901003987891, 0.03748550155365887;
%   -0.01624095229582852, 0.9998564818205395, 0.004821538134006965;
%   -0.0374027407887994, -0.00542632824227644, 0.9992855397449185];
% CalibMat.trans = [-4.672867184359712;
%   0.08985783911144951;
%   -1.53686618071908];
% CalibMat.cam_0_mat = [CalibMat.cam_0, zeros(3,1)];
% CalibMat.cam_1_mat = CalibMat.cam_1 * [(CalibMat.rot), CalibMat.trans];
% ParaSet.M = zeros(CamInfo.HEIGHT*CamInfo.WIDTH, 3);
% ParaSet.D = zeros(CamInfo.HEIGHT*CamInfo.WIDTH, 3);
% for h_cam = 1:CamInfo.HEIGHT
%     for w_cam = 1:CamInfo.WIDTH
%         cvec_idx = (h_cam-1)*CamInfo.WIDTH + w_cam;
%         x_cam = w_cam - 1;
%         y_cam = h_cam - 1;
%         tmp_vec = [(x_cam - CalibMat.cam_0(1,3)) / CalibMat.cam_0(1,1); ...
%             (y_cam - CalibMat.cam_0(2,3)) / CalibMat.cam_0(2,2); ...
%             1];
%         ParaSet.M(cvec_idx,:) = (CalibMat.cam_1_mat(:,1:3)*tmp_vec)';
%         ParaSet.D(cvec_idx,:) = CalibMat.cam_1_mat(:,4)';
%     end
% end

new_depth_mat = zeros(CamInfo.HEIGHT, CamInfo.WIDTH);
% h_0 = 102;
% w_0 = 887;
h_0 = 572;
w_0 = 854;
patch_0 = cam_mat_0(...
    h_0 - CamInfo.win_rad:h_0 + CamInfo.win_rad, ...
    w_0 - CamInfo.win_rad:w_0 + CamInfo.win_rad);
% check patch_0 is valid or not
max_0 = max(max(patch_0));
min_0 = min(min(patch_0));
patch_0 = (patch_0 - min_0) / (max_0 - min_0);
mask_mat(h_0,w_0) = 1;
cvec_idx = (h_0-1)*CamInfo.WIDTH + w_0;
M = ParaSet.M(cvec_idx,:);
D = ParaSet.D(cvec_idx,:);
A = EpiLine.lineA(h_0, w_0);
B = EpiLine.lineB(h_0, w_0);
min_val = 1e15;
min_val_vec = 1e5 * ones(CamInfo.WIDTH, 1);
min_h_idx = 0;
min_w_idx = 0;
min_depth = 0;
epi_show = cam_mat_1;
for w_1 = CamInfo.win_rad+1:CamInfo.WIDTH-CamInfo.win_rad
  x_1 = w_1 - 1;
  depth = - (D(1)-D(3)*x_1) / (M(1)-M(3)*x_1);
  h_center = round(-A/B * x_1 + 1/B + 1);
  if (h_center <= 0) || (h_center > CamInfo.HEIGHT)
    continue;
  end
  epi_show(h_center,w_1) = 255;
  for h_1 = h_center-2:h_center+2
    if (h_1 >= CamInfo.win_rad+1) && (h_1 <= CamInfo.HEIGHT-CamInfo.win_rad)
      patch_1 = cam_mat_1(...
          h_1 - CamInfo.win_rad:h_1 + CamInfo.win_rad, ...
          w_1 - CamInfo.win_rad:w_1 + CamInfo.win_rad);
      patch_1 = (patch_1 - min_1) / (max_1 - min_1);
      max_1 = max_val_cam_1(h_1, w_1);
      min_1 = min_val_cam_1(h_1, w_1);
      if (max_1 - min_1 < ParaSet.lumi_thred)
        continue;
      end
      error_value = sum(sum((patch_0 - patch_1).^2));
      if min_val_vec(w_1) > error_value
          min_val_vec(w_1) = error_value;
      end
      if error_value < min_val
        min_val = error_value;
        min_h_idx = h_1;
        min_w_idx = w_1;
        min_depth = depth;
      end
    end
  end
end
figure(1), plot(min_val_vec);