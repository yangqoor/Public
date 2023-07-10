function error_value = fun_ErrorFunction(cam_est_vecs, ...
    cam_obs_vecs, ...
    depth_vecs, ...
    theta, ...
    ParaSet)
% Calculate E

    flow_size = size(cam_est_vecs,1);
    error_value = 0;
    
    sum_data_val = 0;
    sum_spa_val = 0;

    for flw_idx = 1:flow_size
        cam_est_vec = cam_est_vecs{flw_idx,1};
        cam_obs_vec = cam_obs_vecs{flw_idx,1};
        depth_vec = depth_vecs{flw_idx,1};

        % data_term
        data_vec = cam_est_vec - cam_obs_vec;
        data_value = sum(data_vec.^2);

        % spatial regular term
        spa_reg_vec = ParaSet.gradOpt * (depth_vec);
        spa_reg_value = sum(spa_reg_vec.^2);

        sum_data_val = sum_data_val + data_value;
        sum_spa_val = sum_spa_val + spa_reg_value;
    end

    % Temporal value
    tem_reg_vec = (depth_vecs{3,1}+depth_vecs{1,1}-2*depth_vecs{2,1});
    tem_reg_value = sum(tem_reg_vec.^2);
    error_value = sum_data_val + theta(1) * sum_spa_val + theta(2) * tem_reg_value;
    fprintf('(%.2e,\t%.2e\t%.2e)', sum_data_val,sum_spa_val,tem_reg_value);
end
