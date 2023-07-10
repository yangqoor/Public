function norm_derv_vec = fun_FineErrorFunctionDerv(cam_est_vecs, ...
    cam_obs_vecs, ...
    cam_est_derv, ...
    depth_coarse_vec, ...
    depth_fine_vec, ...
    theta, ...
    lambda, ...
    ParaSet)

    frm_num = size(cam_est_vecs, 1);

    % Data term
    sum_data_derv = zeros(size(depth_fine_vec));
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
    r_minus_vec = (depth_fine_vec - depth_coarse_vec);
    regular_derv = 2 * r_minus_vec;
    
    spatial_vec = ParaSet.gradOpt * depth_fine_vec;
    spatial_derv = ParaSet.gradOpt * spatial_vec;

    derv_vec = sum_data_derv + theta*spatial_derv + lambda*regular_derv;
    norm_derv_vec = derv_vec / norm(derv_vec);
end
