function [ output_mat ] = GetDeltaDepthVectorOnPoint(h_qry, ...
    w_qry, ...
    start_frame_num, ...
    end_frame_num, ...
    delta_depth_mats, ...
    mask_mats)
%SHOWDELTADEPTHFIELDONPOINT Get delta depth vector, for debug
%   blabla

    frame_vector = (1:1:end_frame_num)';
    delta_depth_vector = zeros(size(frame_vector));
    mask_vector = zeros(size(frame_vector));
    
    for i = start_frame_num:1:end_frame_num
        delta_depth_vector(i, 1) = delta_depth_mats{i, 1}(h_qry, w_qry);
        mask_vector(i, 1) = mask_mats{i, 1}(h_qry, w_qry);
    end
    
    output_mat = [frame_vector, delta_depth_vector, mask_vector];
end

