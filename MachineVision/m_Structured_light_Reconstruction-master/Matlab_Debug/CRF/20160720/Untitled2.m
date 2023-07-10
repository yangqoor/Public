% %% Load part
% delta_depth_mats = cell(20, 1);
% mask_mats = cell(20, 1);
% for i = 2:17
%     load(['depth_mat/delta_frame_', num2str(i), '.mat']);
%     delta_depth_mats{i, 1} = total_delta_depth_mat;
%     load(['depth_mat/mask_mat', num2str(i), '.mat']);
%     mask_mats{i, 1} = mask_mat;
% end
% 
% %% Show part
% h = 200 + 101 - 1;
% w = 600 + 101 - 1;
% show_vec = GetDeltaDepthVectorOnPoint(h, w, 2, 17, delta_depth_mats, mask_mats);
% figure;
% plot(show_vec(:,1), show_vec(:,2));

%% Show mask_mats
for i = 2:17
    my_cimshow(delta_depth_mats{i, 1}, mask_mats{i, 1}, viewportMatrix);
end