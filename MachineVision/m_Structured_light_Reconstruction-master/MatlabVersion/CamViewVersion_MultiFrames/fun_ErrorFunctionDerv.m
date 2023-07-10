function norm_derv_vecs = fun_ErrorFunctionDerv(cam_est_vecs, ...
    cam_obs_vecs, ...
    projected_derv_vecmats, ...
    depth_vecs, ...
    theta, ...
    ParaSet)
% Calculate E derv

    flow_size = size(cam_est_vecs,1);
    norm_derv_vecs = cell(flow_size,1);
    tem_para = [2,-4,2];

    for flw_idx = 1:flow_size
        cam_est_vec = cam_est_vecs{flw_idx,1};
        cam_obs_vec = cam_obs_vecs{flw_idx,1};
        depth_vec = depth_vecs{flw_idx,1};
        projected_derv_vecmat = projected_derv_vecmats{flw_idx,1};

        % data Term
        data_vec = cam_est_vec - cam_obs_vec;
        data_derv = 2 * (data_vec' * projected_derv_vecmat)';

        % spatial regular Term
        spa_reg_vec = ParaSet.gradOpt * depth_vec;
        spa_reg_derv = ParaSet.gradOpt * spa_reg_vec;

        % Temporal regular term
        tem_reg_vec = (depth_vecs{3,1}+depth_vecs{1,1}-2*depth_vecs{2,1});
        tem_reg_derv = tem_para(flw_idx) * tem_reg_vec;

        derv_vec = data_derv + theta(1)*spa_reg_derv + theta(2)*tem_reg_derv;
        norm_derv_vecs{flw_idx,1} = derv_vec / norm(derv_vec);
    end
end
