clear;

% Initial process
start_frame = 1;
fprintf('Init...');
part_PreProcess
fprintf('finished.\n');

% Iteration Part
therd_coarse = 1e4;
therd_fine = 1e4;
show_flag = true;
for frm_idx = start_frame+1:total_frame_num
    % start of frame
    part_FramePreProcess

    % iteration of high_level depth_vecs
    fprintf('C_%d:\n', frm_idx);
    part_CoarseIteration

    % iteration of low_level depth_vecs
    fprintf('F_%d:\n', frm_idx);
    part_FineIteration
    % depth_fine_vecs{frm_idx,1} = depth_coarse_vecs{frm_idx,1};

    % frame finish
    part_FrameLastProcess
end
save status.mat

% iteration_times_1 = zeros(20,1);
% for i = 1:20
%     for j = 1:100
%         if error_value(i,j) == 0
%             iteration_times_1(i) = j;
%             break;
%         end
%     end
% end

% MainLoop;
% img = zeros(1024,1280);
% for h_pro = 1:ProInfo.RANGE_HEIGHT
%     for w_pro = 1:ProInfo.RANGE_WIDTH
%         h_cam = round(corres_mat{h_pro,w_pro}(1,2));
%         w_cam = round(corres_mat{h_pro,w_pro}(1,1));
%         img(h_cam,w_cam) = 1.0;
%     end
% end
