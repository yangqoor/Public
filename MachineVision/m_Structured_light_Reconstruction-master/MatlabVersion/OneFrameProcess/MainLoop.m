clear;

part_PreProcess;
% load status.mat

for frm_idx = 2:total_frame_num
    fprintf('F%d:', frm_idx);
    
    % frame start prepare
    part_FramePreProcess;

    % frame process
    part_FrameProcess;

    imshow(x_pro_mats{frm_idx,1},[]);
    
    % last
    part_FrameLastProcess;
    
    fprintf('\n');
end

% output
save status.mat
