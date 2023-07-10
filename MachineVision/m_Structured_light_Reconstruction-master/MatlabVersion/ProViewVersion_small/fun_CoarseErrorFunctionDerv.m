function norm_derv_vec = fun_CoarseErrorFunctionDerv(cam_est_vecs, ...
    cam_obs_vecs, ...
    cam_est_derv, ...
    d_depth_coarse_vec, ...
    theta, ...
    ParaSet)

    frm_num = size(cam_est_vecs, 1);
    
    % Data term
    sum_data_derv = zeros(size(d_depth_coarse_vec));
    for frm_idx = 1:frm_num-1
%         minus_vec = (cam_est_vecs{frm_num,1}./cam_est_vecs{frm_idx,1} ...
%             - cam_obs_vecs{frm_num,1}./cam_obs_vecs{frm_idx,1});
        minus_vec = (cam_est_vecs{frm_num,1} - cam_obs_vecs{frm_num,1});
%         data_derv = 2 * ((minus_vec./cam_est_vecs{frm_idx,1})' ...
%             * cam_est_derv)';
        data_derv = 2 * (minus_vec' * cam_est_derv)';
        sum_data_derv = sum_data_derv + data_derv;
    end

    % Regular Term
    regular_vec = ParaSet.gradOptC * d_depth_coarse_vec;
    regular_derv = ParaSet.gradOptC * regular_vec;

    derv_vec = sum_data_derv + theta * regular_derv;
    norm_derv_vec = derv_vec / norm(derv_vec);
end
