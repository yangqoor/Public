% % Set parameters
% clear;
% CamInfo.HEIGHT = 1024;
% CamInfo.WIDTH = 1280;
% ProInfo.HEIGHT = 800;
% ProInfo.WIDTH = 1280;
% FilePath.main_file_path = 'E:/Structured_Light_Data/20171211/EpiLineSet/';
% FilePath.xpro_file_path = 'pro/';
% FilePath.xpro_file_name = 'xpro_mat';
% FilePath.ypro_file_path = 'pro/';
% FilePath.ypro_file_name = 'ypro_mat';
% FilePath.pro_file_suffix = '.txt';
% FilePath.img_file_path = 'dyna/';
% FilePath.img_file_name = 'dyna_mat';
% FilePath.img_file_suffix = '.png';
% total_frame_num = 16;
% 
% % Create lineA, lineB, lineC
% EpiLine.lineA = zeros(CamInfo.HEIGHT, CamInfo.WIDTH);
% EpiLine.lineB = zeros(size(EpiLine.lineA));
% EpiLine.lineC = ones(size(EpiLine.lineA));
% xdis_threhold = 10;
% xnum_threhold = 5;
% 
% % Fill valid points
% valid_points = cell(CamInfo.HEIGHT, CamInfo.WIDTH);
% for frame_idx = 0:total_frame_num-1
%   fprintf(['F', num2str(frame_idx), ': ']);
%   % Load and Intersect
%   xpro_mat_0 = load(...
%     [FilePath.main_file_path, 'cam_0/', FilePath.xpro_file_path, ...
%     FilePath.xpro_file_name, num2str(frame_idx), FilePath.pro_file_suffix]);
%   ypro_mat_0 = load(...
%     [FilePath.main_file_path, 'cam_0/', FilePath.ypro_file_path, ...
%     FilePath.ypro_file_name, num2str(frame_idx), FilePath.pro_file_suffix]);
%   for h_0 = 1:CamInfo.HEIGHT
%     for w_0 = 1:CamInfo.WIDTH
%       x_pro_0 = xpro_mat_0(h_0, w_0);
%       y_pro_0 = ypro_mat_0(h_0, w_0);
%       if (x_pro_0 < 0 || y_pro_0 < 0)
%         continue;
%       end
%       valid_points{h_0, w_0} = [valid_points{h_0, w_0}; x_pro_0, y_pro_0];
%     end
%   end
% end

fprintf('Calculation...\n');
error_valid_mat = zeros(CamInfo.HEIGHT, CamInfo.WIDTH);
for h_0 = 1:CamInfo.HEIGHT
  for w_0 = 1:CamInfo.WIDTH
    if size(valid_points{h_0, w_0},1) < xnum_threhold
      continue;
    end
    xmax_val = max(valid_points{h_0, w_0}(:,1));
    xmin_val = min(valid_points{h_0, w_0}(:,1));
    if xmax_val - xmin_val > xdis_threhold
      vecY = ones(size(valid_points{h_0,w_0},1),1);
      vecX = valid_points{h_0,w_0} \ vecY;
      error_value = sum((valid_points{h_0,w_0}*vecX - vecY).^2);
      if error_value > 1e-4
        continue;
      end
      error_valid_mat(h_0,w_0) = error_value;
      EpiLine.lineA(h_0,w_0) = vecX(1);
      EpiLine.lineB(h_0,w_0) = vecX(2);
    end
  end
end
imshow(error_valid_mat, []);

valid_mat = zeros(CamInfo.HEIGHT, CamInfo.WIDTH);
for h_0 = 2:CamInfo.HEIGHT-1
  for w_0 = 2:CamInfo.WIDTH-1
    if EpiLine.lineA(h_0, w_0) == 0
      if (EpiLine.lineA(h_0, w_0-1) ~= 0) && (EpiLine.lineA(h_0, w_0+1) ~= 0)
        EpiLine.lineA(h_0, w_0) = (EpiLine.lineA(h_0, w_0-1) + EpiLine.lineA(h_0, w_0+1)) / 2;
        EpiLine.lineB(h_0, w_0) = (EpiLine.lineB(h_0, w_0-1) + EpiLine.lineB(h_0, w_0+1)) / 2;
        valid_mat(h_0, w_0) = 1.0;
      else
        if (EpiLine.lineA(h_0-1, w_0) ~= 0) && (EpiLine.lineA(h_0+1, w_0) ~= 0)
          EpiLine.lineA(h_0, w_0) = (EpiLine.lineA(h_0-1, w_0) + EpiLine.lineA(h_0+1, w_0)) / 2;
          EpiLine.lineB(h_0, w_0) = (EpiLine.lineB(h_0-1, w_0) + EpiLine.lineB(h_0+1, w_0)) / 2;
          valid_mat(h_0, w_0) = 1.0;
        end
      end
    else
      valid_mat(h_0, w_0) = 1.0;
    end
  end
end
imshow(valid_mat);

save('EpiLineParaCamPro.mat', 'EpiLine');
save('statusCamPro.mat');
