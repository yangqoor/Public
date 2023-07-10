function error_value = fun_CoarseErrorFunction(new_cam_est_vec, ...
    cam_est_vecs, ...
    cam_obs_vecs, ...
    d_depth_coarse_vec, ...
    theta, ...
    ParaSet)

    frm_num = size(cam_obs_vecs, 1);

    sum_data_value = 0;
    sum_data_vec = zeros(size(new_cam_est_vec));
    for frm_idx = 1:frm_num-1
%         data_vec = (new_cam_est_vec./cam_est_vecs{frm_idx,1} ...
%             - cam_obs_vecs{frm_num,1}./cam_obs_vecs{frm_idx,1});
        data_vec = (new_cam_est_vec - cam_obs_vecs{frm_num,1});
        data_value = sum(data_vec.^2);
        sum_data_vec = sum_data_vec + data_vec;
        sum_data_value = sum_data_value + data_value;
    end

    regular_vec = ParaSet.gradOptC * d_depth_coarse_vec;
    regular_value = sum(regular_vec.^2);

    error_value = sum_data_value + theta * regular_value;
end
