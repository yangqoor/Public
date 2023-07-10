function cam_est_vecs = fun_CalculateEstVecs(projected_vecmats, envir_light)
% Calculate est_vecs from vecmats

    flow_size = size(projected_vecmats,1);
    cam_est_vecs = cell(flow_size,1);

    for flw_idx = 1:flow_size
        cam_est_vecs{flw_idx,1} = sum(projected_vecmats{flw_idx,1},2) + envir_light;
    end
end
